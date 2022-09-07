# frozen_string_literal: true
require 'sidekiq/web'

class BearerTokenConstraint
  include BearerTokenHelper

  # pros: we know for sure that the token is valid
  # cons: relies on external service for token check
  def self.matches?(request)
    token = request.params[:token] || request.session[:token]
    return unless token.present?

    user = new.find_user_from_token(token)
    if user
      request.session[:token] = token
    end

    user.present?
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
      mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
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
