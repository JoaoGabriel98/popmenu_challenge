Rails.application.routes.draw do
  resources :restaurants, only: [ :index, :show, :create ] do
    resources :menus, only: [ :index, :create, :show ] do
      member do
        post   "menu_items/:menu_item_id/link",   to: "menus#link_item",   as: :link_item
        delete "menu_items/:menu_item_id/unlink", to: "menus#unlink_item", as: :unlink_item
      end
    end

    resources :menu_items, only: [ :index, :create, :show, :update, :destroy ]
  end

  resources :menus, only: [ :index, :show ]
  resources :menu_items, only: [ :index, :show ]
end
