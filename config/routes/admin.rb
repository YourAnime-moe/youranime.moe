# frozen_string_literal: true

require 'sidekiq/web'

class StaffConstraint
  def matches?(request)
    return unless Config.viewing_as_admin_from?(request)
    return unless request.session[:user_id].present?

    current_user = User.find_by(id: request.session[:user_id])
    current_user.present? && current_user.can_manage?
  end
end

Rails.application.routes.draw do
  constraints StaffConstraint.new do
    get '/admin' => 'admin/application#home'
    namespace :admin do
      mount Sidekiq::Web => '/sidekiq'

      resources :shows do
        post :process_csv, on: :collection
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
  end
end
