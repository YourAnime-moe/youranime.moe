# frozen_string_literal: true
require 'sidekiq/web'

class BearerTokenConstraint
  include BearerTokenHelper

  # pros: we know for sure that the token is valid
  # cons: relies on external service for token check
  def self.matches?(request)
    token = request.params[:token]
    return unless token.present?

    new.find_user_from_token(token)
  end
end

Rails.application.routes.draw do
  get '/', to: redirect('/login')
  get '/home', to: redirect('/admin')

  # Admin console
  get '/admin' => 'admin/application#home'
  namespace :admin do
    constraints(BearerTokenConstraint) do
      mount Sidekiq::Web => '/sidekiq'
    end

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

    post "/graphql", to: 'graphql#execute'
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
