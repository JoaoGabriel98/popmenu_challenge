class MenusController < ApplicationController
  before_action :set_menu, only: [:show, :update, :destroy]

  def index
    menus = Menu.order(created_at: :desc)
    render json: menus.as_json(only: [:id, :name, :description, :created_at, :updated_at])
  end

  def show
    render json: @menu.as_json(
      only: [:id, :name, :description, :created_at, :updated_at],
      include: { menu_items: { only: [:id, :name, :description, :price_cents, :available] } }
    )
  end

  def create
    menu = Menu.new(menu_params)
    if menu.save
      render json: menu, status: :created
    else
      render json: { errors: menu.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @menu.update(menu_params)
      render json: @menu
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @menu.destroy
    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description)
  end
end
