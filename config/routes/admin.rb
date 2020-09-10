# frozen_string_literal: true

require 'sidekiq/web'

class StaffConstraint
  def matches?(request)
    return unless request.session[:user_id].present?

    Staff.where(id: request.session[:user_id]).present?
  end
end

Rails.application.routes.draw do
  constraints StaffConstraint.new do
    get '/admin' => 'admin/application#home'
  end
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :shows do
      post :process_csv, on: :collection
      post :sync, on: :collection
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
  end
end
