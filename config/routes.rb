Rails.application.routes.draw do
  get 'export', to: 'my_episodes#index'
  post 'export', to: 'my_episodes#export'

  root 'trakter#index'
end
