Rails.application.routes.draw do
  resources :export, only: [:new, :create, :show, :destroy]

  root 'trakter#index'
end
