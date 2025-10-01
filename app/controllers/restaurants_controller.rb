class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [ :show ]

  def index
    restaurants = Restaurant.order(:name)
    render json: restaurants.as_json(only: [ :id, :name, :slug ])
  end

  def show
    render json: @restaurant.as_json(
      only: [ :id, :name, :slug, :created_at, :updated_at ],
      include: {
        menus: { only: [ :id, :name, :description ] }
      }
    )
  end

  def create
    restaurant = Restaurant.new(restaurant_params)
    if restaurant.save
      render json: restaurant, status: :created
    else
      render json: { errors: restaurant.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :slug)
  end
end
