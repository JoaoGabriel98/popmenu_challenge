class MenuItemsController < ApplicationController
  before_action :set_restaurant, only: [:index, :create]
  before_action :set_menu_item, only: [:show, :update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items
  # GET /menu_items?restaurant_id=...&available=true&q=...
  def index
    scope = if @restaurant
      @restaurant.menu_items
    elsif params[:restaurant_id]
      Restaurant.find(params[:restaurant_id]).menu_items
    else
      MenuItem.all
    end

    scope = scope.where(available: cast_bool(params[:available])) if params.key?(:available)
    scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    render json: scope.order(:name).as_json(only: [:id, :restaurant_id, :name, :description, :price_cents, :available])
  end

  # POST /restaurants/:restaurant_id/menu_items
  def create
    item = @restaurant.menu_items.new(menu_item_params)
    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    render json: @menu_item.as_json(only: [:id, :restaurant_id, :name, :description, :price_cents, :available, :created_at, :updated_at])
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id]) if params[:restaurant_id]
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price_cents, :available)
  end

  def cast_bool(val)
    ActiveModel::Type::Boolean.new.cast(val)
  end
end
