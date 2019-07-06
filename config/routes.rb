# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#root'

  get '/google' => 'application#welcome_google'

  # Admin console
  get '/admin' => 'admin#home'
  namespace :admin do
    resources :shows do
      resources :episodes, except: [:new] do
        post :subtitles, to: 'episodes#create_subs'
      end
    end
  end

  # API interface
  namespace :api, defaults: { format: :json } do
    get '/', to: "v#{Config.api_version}/default_action#home"
    namespace "v#{Config.api_version}" do
      resources :session, only: %i[create show destroy], param: :token
      resources :shows, only: %i[index show] do
        resources :episodes, only: [:index]
        get :search, on: :collection
        get :latest, on: :collection
      end

      resources :episodes, only: [:show] do
        get :watched, on: :collection
      end

      resources :users, only: [:index]
    end
    match '*all', to: "v#{Config.api_version}/default_action#not_found", via: :all, constraints: { all: /.*/ }
  end

  get '/home' => 'application#home'

  # Issues
  resources :issues, only: %i[index new] do
    delete :close
    post :open, on: :collection
  end

  # Shows
  resources :shows, only: %i[index show] do
    resources :episodes, only: %i[show update]
  end

  # User links
  scope :users do
    get :settings, to: 'users#settings', as: :users_settings
    get :home, to: 'users#home', as: :users_home
    patch 'update/:id', to: 'users#update', as: :user_update
  end

  # Locale management
  get '/get/current/locale' => 'application#locale'
  put '/set/current/locale' => 'application#set_locale'

  # Google OAuth2
  get '/auth/google_oauth2/callback' => 'application#google_auth'
  post '/welcome/google/user' => 'application#google_register'

  # Authentication
  get '/login' => 'application#root'
  delete '/logout' => 'application#logout'
  post '/login' => 'application#login_post'

  constraints(host: /localhost|0.0.0.0/) do
    match '/prod' => redirect('https://anime.akinyele.ca'), via: [:get]
  end

  constraints(host: /\w+\.herokuapp.com/) do
    match '/(*path)' => redirect { |params, _| "https://anime.akinyele.ca/#{params[:path]}" }, via: :all
  end
end
