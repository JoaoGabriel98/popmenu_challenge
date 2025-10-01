module Importers
  class RestaurantDataImporter
    # {
    #   success: true/false,
    #   errors_count: Integer,
    #   logs: [ {scope:, action:, ...}, ... ]
    # }
    def initialize(payload:, logger: Rails.logger)
      @payload = payload
      @logger  = logger
      @logs    = []
      @errors  = 0
    end

    def call
      restaurants = Array(@payload["restaurants"])
      if restaurants.empty?
        log_error("import", nil, [ "No restaurants found in payload" ])
        return result(false)
      end

      restaurants.each_with_index do |rest_json, r_idx|
        import_one_restaurant(rest_json, r_idx)
      end

      result(@errors.zero?)
    rescue => e
      @logger.error(e.full_message)
      log_error("import", nil, [ e.message ])
      result(false)
    end

    private

    def import_one_restaurant(rest_json, r_idx)
      ActiveRecord::Base.transaction do
        restaurant = upsert_restaurant!(rest_json)

        Array(rest_json["menus"]).each_with_index do |menu_json, m_idx|
          menu = upsert_menu!(restaurant, menu_json)

          # Itens podem vir como "menu_items" ou "dishes"
          items = Array(menu_json["menu_items"]) + Array(menu_json["dishes"])
          next if items.empty?

          # Evitar processar duplicados no mesmo menu pelo mesmo nome
          seen_names = Set.new

          items.each_with_index do |item_json, i_idx|
            name = item_json["name"].to_s.strip
            price = item_json["price"]

            if name.blank?
              log_error("menu_item", nil, [ "Missing name" ], menu:, restaurant:)
              next
            end

            # se o mesmo nome aparecer repetido dentro do mesmo menu no payload
            if seen_names.include?(name.downcase)
              @logs << {
                scope: "menu_item",
                name: name,
                action: "skipped_duplicate_in_payload",
                restaurant: restaurant.name,
                menu: menu.name
              }
              next
            end
            seen_names.add(name.downcase)

            begin
              item = upsert_menu_item!(restaurant, name, item_json)

              # Vincula ao menu com preço específico do menu (override)
              link_item_to_menu!(menu, item, price, i_idx)
            rescue ActiveRecord::RecordInvalid => e
              log_error("menu_item", name, e.record.errors.full_messages, menu:, restaurant:)
            rescue => e
              log_error("menu_item", name, [ e.message ], menu:, restaurant:)
            end
          end
        end
      end
    end

    def upsert_restaurant!(h)
      name = h["name"].to_s.strip
      slug = name.parameterize
      r = Restaurant.find_or_initialize_by(slug: slug)
      r.name = name.presence || "Unnamed Restaurant"
      r.save!
      @logs << { scope: "restaurant", name: r.name, action: r.previous_changes.key?("id") ? "created" : "updated" }
      r
    end

    def upsert_menu!(restaurant, h)
      name = h["name"].to_s.strip
      m = restaurant.menus.find_or_initialize_by(name: name)
      m.description = h["description"]
      m.save!
      @logs << { scope: "menu", name: m.name, restaurant: restaurant.name, action: m.previous_changes.key?("id") ? "created" : "updated" }
      m
    end

    # Cria/atualiza MenuItem (único por restaurante pelo nome)
    # Define price_cents do item se ainda não tiver (primeira ocorrência).
    def upsert_menu_item!(restaurant, name, h)
      item = restaurant.menu_items.find_or_initialize_by(name: name)
      item.description ||= h["description"]
      item.available = h.key?("available") ? !!h["available"] : true

      # preço padrão do item (usamos na ausência de preço por menu)
      if item.price_cents.nil?
        price_cents = extract_price_cents(h["price"], h["price_cents"])
        item.price_cents = price_cents if price_cents
      end

      item.save!
      @logs << { scope: "menu_item", name: item.name, restaurant: restaurant.name, action: item.previous_changes.key?("id") ? "created" : "updated" }
      item
    end

    # Cria o vínculo Menu <-> Item e salva price_cents específico do menu
    def link_item_to_menu!(menu, item, price, position)
      mi = MenuItemization.find_or_initialize_by(menu: menu, menu_item: item)
      mi.position = position
      mi.price_cents = extract_price_cents(price, nil) || mi.price_cents || item.price_cents || 0
      mi.save!

      @logs << {
        scope: "menu_itemization",
        action: "linked",
        menu: menu.name,
        restaurant: menu.restaurant.name,
        menu_item: item.name,
        price_cents: mi.price_cents
      }
      mi
    end

    def extract_price_cents(price, price_cents)
      return price_cents.to_i if price_cents
      return nil if price.nil?
      ((price.to_f) * 100).round
    end

    def log_error(scope, name, errors, menu: nil, restaurant: nil)
      @errors += 1
      @logs << { scope:, name:, action: "error", restaurant: restaurant&.name || restaurant, menu: menu&.name || menu, errors: Array(errors) }
    end

    def result(success)
      { success: success, errors_count: @errors, logs: @logs }
    end
  end
end
