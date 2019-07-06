# frozen_string_literal: true

class User < ApplicationRecord
  serialize :episodes_watched
  serialize :episode_progress_list
  serialize :settings

  has_one_attached :avatar
  has_many :progresses, lambda {
    includes(:episode).includes(:show).where('progress > 1')
  }, class_name: 'UserWatchProgress', inverse_of: :user

  DEFAULT_DEMO_NAME = 'Demo Account'
  DEFAULT_DEMO_USERNAME = 'demo'
  DEFAULT_DEMO_TOKEN = 'demo'

  before_save :check_user
  has_secure_token :auth_token
  has_secure_password

  def auth_token
    demo? ? DEFAULT_DEMO_TOKEN : self[:auth_token]
  end

  def username
    demo? ? DEFAULT_DEMO_USERNAME : self[:username]
  end

  def name
    return DEFAULT_DEMO_NAME if demo?

    self['name'] || self['username']
  end

  # All episodes this user is able to view
  def episodes_data(show)
    show.episodes.map do |episode|
      episode.as_json.merge(
        progress: progress_for(episode)
      )
    end
  end

  def progress_for(episode)
    actual_progress = history.select { |e| e.id == episode.id }.first
    return if actual_progress.nil?

    actual_progress.user_watch_progress.progress
  end

  def history(*)
    progresses.map(&:episode)
  end
  alias currently_watching history

  def allows_setting(what)
    return get_default(what) if settings.class != Hash

    is_ok(what, get_default(what))
  end

  def admin?
    super && !demo? && activated?
  end

  def activated?
    # All users should be activated by default. They will be deactivated on request.
    was_nil = is_activated.nil?
    update(is_activated: true) if was_nil
    is_activated
  end

  def destroy_token
    update(:auth_token, nil)
  end

  def as_json(_options = {})
    keys = %i[username name limited google_user]
    super(only: keys).tap do |hash|
      hash[:active] = is_activated?
      hash[:admin] = admin?
      hash[:demo] = demo?
    end
  end

  def self.find_by_token(token)
    find_by auth_token: token
  end

  def self.from_omniauth(auth)
    where(username: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.username = auth.info.email
    end
  end

  private

  def check_user
    self.episodes_watched = [] if episodes_watched.nil?
    self.episode_progress_list = [] if episode_progress_list.nil?

    if demo?
      found_user = User.find_by(demo: true)
      unless found_user.nil? || found_user.id == id
        errors.add 'username', "\"#{found_user.username}\" is already a demo account. Only one demo account is allowed."
        throw :abort
      end
    else
      if username.nil? || username.strip.empty?
        errors.add 'username', 'cannot be empty'
        throw :abort
      end

      found_user = User.find_by(username: username)
      unless found_user.nil? || found_user.id == id
        errors.add 'username', "\"#{username}\" already exists"
        throw :abort
      end
    end
  end
end
