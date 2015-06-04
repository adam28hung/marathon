Rails.application.routes.draw do
  require 'sidekiq/web'
  # root "pages#index"

  resources :contests , only: [:index, :show] do 
    collection do
      get 'fetch_next_page' => 'contests#fetch_next_page'

      get 'search' => 'contests#search'
      post 'search' => 'contests#search'

      get ':photo_id/share' => 'contests#share', as: 'share'
    end
  end
  
  # authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  # end
  
end
