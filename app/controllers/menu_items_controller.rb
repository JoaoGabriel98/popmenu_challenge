class MenuItemsController < ApplicationController
  before_action :set_menu, only: [:index, :create]
  before_action :set_menu_item, only: [:show, :update, :destroy]

  # GET /menus/:menu_id/menu_items  (itens de um menu específico)
  # GET /menu_items?available=true&q=pepper  (todos os itens com filtros)
  def index
    scope = @menu ? @menu.menu_items : MenuItem.all

    if params.key?(:available)
      scope = scope.where(available: ActiveModel::Type::Boolean.new.cast(params[:available]))
    end

    if params[:q].present?
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%")
    end

    items = scope.order(:name)
    render json: items.as_json(only: [:id, :menu_id, :name, :description, :price_cents, :available])
  end

  def show
    render json: @menu_item.as_json(only: [:id, :menu_id, :name, :description, :price_cents, :available, :created_at, :updated_at])
  end

  def create
    item = @menu.menu_items.new(menu_item_params)
    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_content
    end
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

  def set_menu
    @menu = Menu.find(params[:menu_id]) if params[:menu_id]
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id]) if params[:id]
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price_cents, :available)
  end
end
