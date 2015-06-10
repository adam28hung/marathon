Rails.application.routes.draw do
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  require 'sidekiq/web'
  
  root "statics#index"
  
  devise_for :members, :controllers => { :omniauth_callbacks => "members/omniauth_callbacks" }
  devise_for :admins#, :path => 'administrator' #, :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  # root "pages#index"
  

  # get 'about' => 'statics#about', :as => :about
  
  resources :pages, :controller => :statics do 
    collection do
      get ':page', :action => :show, :as => :page
    end
  end

  resources :contests , only: [:index, :show] do 
    collection do
      match 'sort' => 'contests#sort', via: [:get, :post], as: :sort
      
      get 'fetch_next_page' => 'contests#fetch_next_page'

      get 'search' => 'contests#search'
      post 'search' => 'contests#search'

      get ':photo_id/share' => 'contests#share', as: 'share'
    end
  end

  namespace :monit do
    mount Sidekiq::Web => '/sidekiq'
  end

end
