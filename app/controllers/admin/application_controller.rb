# frozen_string_literal: true
module Admin
  class ApplicationController < ::ApplicationController
    layout 'admin'

    before_action :ensure_logging_in_as_admin
    before_action :ensure_title

    def home
      @users_count = Users::Regular.count
      @oauth_users_count = GraphqlUser.count
      @shows_count = Show.published.count
      @currently_watching_count = 0
      @currently_logged_in_count = currently_logged_in.count
      @top_episodes = Episode.includes(season: :show).limit(10)
      @latest_events = JobEvent.latest.limit(10)
      @latest_additions = Show.recent.limit(10)
    end

    private

    def currently_logged_in
      Users::Session.all.select(&:active?).map(&:user).uniq
    end

    def ensure_title
      set_title(after: 'Admin panel')
    end
  end
end
