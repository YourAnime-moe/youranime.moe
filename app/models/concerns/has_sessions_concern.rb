# frozen_string_literal: true
module HasSessionsConcern
  extend ActiveSupport::Concern

  def sessions
    @sessions ||= Users::Session.where(user_id: id, user_type: user_type)
  end

  def active_sessions
    sessions.where(deleted: false).order('created_at desc')
  end

  def auth_token
    @auth_token ||= active_sessions.first&.token
  end

  def delete_auth_token!
    active_sessions.first&.delete!
  end

  def delete_all_auth_token!
    active_sessions.each(&:delete!)
  end
end
