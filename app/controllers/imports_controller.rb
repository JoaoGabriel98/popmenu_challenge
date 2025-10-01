class ImportsController < ApplicationController
  # POST /imports/restaurant_json
  def restaurant_json
    payload =
      if params[:file].present?
        raw = JSON.parse(params[:file].read)
        sanitize_import_payload(ActionController::Parameters.new(raw))
      else
        sanitize_import_payload(params.require(:data))
      end

    result = Importers::RestaurantDataImporter.new(payload: payload).call
    render json: result, status: (result[:success] ? :ok : :unprocessable_content)
  rescue ActionController::ParameterMissing => e
    render json: { success: false, errors_count: 1, logs: [{ scope: "import", action: "error", errors: [e.message] }] },
           status: :unprocessable_content
  end

  private

  # Strong Parameters for the importer payload
  def sanitize_import_payload(params_obj)
    schema = {
      restaurants: [
        :name, :slug,
        {
          menus: [
            :name, :description,
            # support either "menu_items" or "dishes"
            { menu_items: [:name, :description, :price, :price_cents, :available] },
            { dishes:     [:name, :description, :price, :price_cents, :available] }
          ]
        }
      ]
    }

    permitted = params_obj.permit(schema)
    permitted.to_h # hand the service a plain Hash
  end
end
