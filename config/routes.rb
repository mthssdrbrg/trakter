Rails.application.routes.draw do
  get 'export', to: 'my_episodes#index'
  post 'export', to: 'my_episodes#export'

  get 'import', to: 'import#index'
  post 'import', to: 'import#import'
  get 'import/status', to: 'import#status'

  root 'trakter#index'
end
