class MenusController < ApplicationController
  before_action :set_restaurant, only: [ :index, :create ]
  before_action :set_menu, only: [ :show, :link_item, :unlink_item ]

  # GET /restaurants/:restaurant_id/menus
  # GET /menus (global list)
  def index
    menus = if @restaurant
      @restaurant.menus.order(:name)
    else
      Menu.all.order(:name)
    end

    render json: menus.as_json(only: [ :id, :restaurant_id, :name, :description ])
  end

  # POST /restaurants/:restaurant_id/menus
  def create
    menu = @restaurant.menus.new(menu_params)
    if menu.save
      render json: menu, status: :created
    else
      render json: { errors: menu.errors.full_messages }, status: :unprocessable_content
    end
  end

  # GET /menus/:id
  def show
    items = @menu.menu_itemizations.includes(:menu_item).order(:position).map do |mi|
      item = mi.menu_item
      {
        id: item.id,
        restaurant_id: item.restaurant_id,
        name: item.name,
        description: item.description,
        price_cents: mi.price_cents || item.price_cents,
        available: item.available
      }
    end

    render json: {
      id: @menu.id,
      restaurant_id: @menu.restaurant_id,
      name: @menu.name,
      description: @menu.description,
      created_at: @menu.created_at,
      updated_at: @menu.updated_at,
      menu_items: items
    }
  end


  # POST /restaurants/:restaurant_id/menus/:id/menu_items/:menu_item_id/link
  def link_item
    item = MenuItem.find_by(id: params[:menu_item_id])
    return render(json: { errors: [ "MenuItem not found" ] }, status: :not_found) unless item

    if item.restaurant_id != @menu.restaurant_id
      return render json: { errors: [ "MenuItem belongs to a different restaurant" ] }, status: :not_found
    end

    link = MenuItemization.find_or_create_by!(menu: @menu, menu_item: item)
    render json: { linked: true, menu_id: @menu.id, menu_item_id: item.id, link_id: link.id }
  end

  # DELETE /restaurants/:restaurant_id/menus/:id/menu_items/:menu_item_id/unlink
  def unlink_item
    item = MenuItem.find_by(id: params[:menu_item_id])
    return render(json: { errors: [ "MenuItem not found" ] }, status: :not_found) unless item

    if item.restaurant_id != @menu.restaurant_id
      return render json: { errors: [ "MenuItem belongs to a different restaurant" ] }, status: :not_found
    end

    MenuItemization.where(menu: @menu, menu_item: item).delete_all
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id]) if params[:restaurant_id]
  end

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description)
  end
end
