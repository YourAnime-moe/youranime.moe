# frozen_string_literal: true

Rails.application.routes.draw do
  constraints subdomain: 'api' do
    get '/', to: "v1/default_action#home"
    namespace :v1, defaults: { format: :json } do
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
    match '*all', to: "v1/default_action#not_found", via: :all, constraints: { all: /.*/ }
  end
end
