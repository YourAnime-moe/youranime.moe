# frozen_string_literal: true

Rails.application.routes.draw do
  get '/auth/google_oauth2/callback' => 'application#google_auth'
  get '/auth/misete/callback' => 'application#misete_auth'
  post '/welcome/google/user' => 'application#google_register'
  post '/welcome/misete/user' => 'application#misete_register'

  # Authentication
  get '/login', to: 'application#login'
  get '/logout' => 'application#logout'
  post '/login' => 'application#login_post'
end
