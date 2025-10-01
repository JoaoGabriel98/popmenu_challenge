class ImportsController < ApplicationController
  # POST /imports/restaurant_json
  def restaurant_json
    payload =
      if params[:file].present?
        JSON.parse(params[:file].read)
      else
        params.require(:data).permit.to_h # wait { data: {...} }
      end

    result = Importers::RestaurantDataImporter.new(payload: payload).call
    status = result[:success] ? :ok : :unprocessable_content

    render json: result, status: status
  rescue ActionController::ParameterMissing => e
    render json: { success: false, errors_count: 1, logs: [ { scope: "import", action: "error", errors: [ e.message ] } ] },
           status: :unprocessable_content
  end
end
