# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  layout 'authenticated'
  include EpisodesHelper

  before_action :ensure_logged_in!

  private

  def ensure_logged_in!
    current_user.sessions.create(active_until: 1.week.from_now) if logged_in? && current_user.auth_token.nil?
    return if logged_in?

    next_url = NextLinkFinder.perform(path: request.fullpath)
    redirect_to "/?next=#{CGI.escape(next_url)}"
  end
end
