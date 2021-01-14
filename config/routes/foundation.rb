# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#home'
  get '/home', to: redirect('/'), as: :home
  get '/google' => 'application#welcome_google'

  resources :issues, only: %i[index new] do
    delete :close
    post :open, on: :collection
  end

  # Shows
  get :search, to: 'shows#search_partial' # POST to protect my server :p

  resources :platforms, only: %i(index show), param: :name do
    get :schedule, on: :collection
  end

  resources :shows, only: %i[index show], param: :slug do
    post :react
    post :queue

    get :action_buttons, to: :action_buttons_partial

    get 'partial/:partial_name', to: 'shows#render_partial', as: :partial

    # Episodes
    resources :episodes, only: %i[show update]
  end

  get '/my/queue', to: 'queues#main'

  get :trending_shows, to: 'application#trending_shows_partial'
  get :main_queue, to: 'application#main_queue_partial'
  get :recommendations, to: 'application#recommendations_partial'
  get :recent_shows, to: 'application#recent_shows_partial'
  get :airing_now, to: 'application#airing_now_partial'
  get :coming_soon, to: 'application#coming_soon_partial'

  # User links
  scope :users do
    get :settings, to: 'users#settings', as: :users_settings
    patch 'update/:id', to: 'users#update', as: :user_update
  end

  # Locale management
  get '/get/current/locale' => 'application#locale'
  put '/set/current/locale' => 'application#set_locale'
end
