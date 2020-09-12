# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#login'
  get '/google' => 'application#welcome_google'

  resources :issues, only: %i[index new] do
    delete :close
    post :open, on: :collection
  end

  # Shows
  resources :shows, only: %i[index show], param: :slug do
    get :history, on: :collection
    get :movies, on: :collection

    # Episodes
    resources :episodes, only: %i[show update]
  end
  get '/my/queue', to: 'queues#main'

  # User links
  scope :users do
    get :settings, to: 'users#settings', as: :users_settings
    get :home, to: 'users#home', as: :users_home
    patch 'update/:id', to: 'users#update', as: :user_update
  end

  # Locale management
  get '/get/current/locale' => 'application#locale'
  put '/set/current/locale' => 'application#set_locale'
end
