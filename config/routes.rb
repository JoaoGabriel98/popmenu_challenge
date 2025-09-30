Rails.application.routes.draw do
  resources :menus do
    resources :menu_items, only: [:index, :create]
  end

  resources :menu_items, only: [:show, :update, :destroy, :index]
end
