# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#login'
  get '/google' => 'application#welcome_google'

  resources :issues, only: %i[index new] do
    delete :close
    post :open, on: :collection
  end

  # Shows
  get :search, to: 'shows#search_partial' # POST to protect my server :p
  resources :shows, only: %i[index show], param: :slug do
    post :react
    post :queue

    get :action_buttons, to: :action_buttons_partial

    get 'partial/:partial_name', to: 'shows#render_partial', as: :partial

    # Episodes
    resources :episodes, only: %i[show update]
  end
  get '/my/queue', to: 'queues#main'

  # User links
  scope :users do
    get :settings, to: 'users#settings', as: :users_settings
    get :home, to: 'users#home', as: :users_home
    patch 'update/:id', to: 'users#update', as: :user_update

    get :trending_shows, to: 'users#trending_shows_partial'
    get :main_queue, to: 'users#main_queue_partial'
    get :recommendations, to: 'users#recommendations_partial'
    get :recent_shows, to: 'users#recent_shows_partial'
  end

  # Locale management
  get '/get/current/locale' => 'application#locale'
  put '/set/current/locale' => 'application#set_locale'
end
