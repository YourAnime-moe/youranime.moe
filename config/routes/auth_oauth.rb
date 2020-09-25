# frozen_string_literal: true

Rails.application.routes.draw do
  get '/auth/:provider/callback' => 'application#oauth_auth'
  post '/welcome/google/user' => 'application#google_register'
  post '/welcome/misete/user' => 'application#misete_register'

  # Authentication
  get '/login', to: 'application#login'
  get '/logout' => 'application#logout'
  post '/login' => 'application#login_post'
end
