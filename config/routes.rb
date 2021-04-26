# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  get '/', to: redirect('/login')
  get '/home', to: redirect('/admin')

  # Admin console
  get '/admin' => 'admin/application#home'
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :shows do
      post :sync, on: :collection
      post :sync_now
      post :sync_episodes

      post :publish
      post :unpublish

      resources :seasons, path: :shows_seasons

      resources :episodes, except: [:new] do
        post :subtitles, to: 'episodes#create_subs'
      end
    end

    resources :users, except: [:new] do
      resources :sessions, only: [:index, :show]
    end

    resources :job_events, only: [:index]
  end

  # API interface
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"

  # Authentication
  get '/login', to: 'application#login'
  get '/logout' => 'application#logout'
  post '/login' => 'application#login_post'

  # Locale management
  get '/get/current/locale' => 'application#locale'
  put '/set/current/locale' => 'application#set_locale'

  constraints(host: /localhost|0.0.0.0/) do
    match '/prod' => redirect('https://youranime.moe'), via: [:get]
  end
end
