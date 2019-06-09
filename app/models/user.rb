# frozen_string_literal: true

class User < ApplicationRecord
  serialize :episodes_watched
  serialize :episode_progress_list
  serialize :settings

  has_one_attached :avatar
  has_many :progresses, lambda {
    includes(:episode).where('progress > 1')
  }, class_name: 'UserWatchProgress'

  DEFAULT_DEMO_NAME = 'Demo Account'
  DEFAULT_DEMO_USERNAME = 'demo'
  DEFAULT_DEMO_TOKEN = 'demo'

  before_save :check_user
  has_secure_token :auth_token
  has_secure_password

  def auth_token
    return DEFAULT_DEMO_TOKEN if is_demo_account?

    self[:auth_token]
  end

  def username
    return DEFAULT_DEMO_USERNAME if is_demo_account?

    self[:username]
  end

  def name
    return DEFAULT_DEMO_NAME if is_demo_account?

    self[:name]
  end

  def get_name
    return username.to_s if name.nil?

    name
  end

  # All episodes this user is able to view
  def episodes_data(show)
    show.episodes.map do |episode|
      episode.as_json.merge(
        progress: episode.progress(self).progress
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

  def is_admin?
    return false if admin.nil?

    admin
  end

  def is_demo_account?
    !!demo
  end

  def is_activated?
    # All users should be activated by default. They will be deactivated on request.
    was_nil = is_activated.nil?
    update(is_activated: true) if was_nil
    is_activated
  end

  def is_demo?
    username == 'demo'
  end

  def update_settings(new_settings, save = true)
    keys = %i[watch_anime last_episode episode_tracking recommendations images autoplay]
    if new_settings.nil? || new_settings.class != Hash
      new_settings = {
        watch_anime: true,
        last_episode: true,
        episode_tracking: true,
        recommendations: true,
        images: true,
        autoplay: true
      }
    end
    self.settings = {} if settings.class != Hash
    keys.each do |setting_key|
      new_value = new_settings[setting_key]
      new_value = new_settings[setting_key.to_s] if new_value.nil?
      next if new_value.nil?

      settings.delete setting_key.to_s if settings.keys.include? setting_key.to_s
      settings[setting_key] = new_value
    end
    save ? self.save : true
  end

  def destroy_token
    update(:auth_token, nil)
  end

  def as_json(_options = {})
    keys = %i[
      username
      name
      limited
      google_user
    ]
    super(only: keys).tap do |hash|
      hash[:active] = is_activated?
      hash[:admin] = is_admin?
      hash[:demo] = is_demo_account?
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

    if is_demo_account?
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

  def is_ok(value, default)
    res = settings[value]
    res = settings[value.to_s] if res.nil?
    res = true if res == 'true'
    res = false if res == 'false'
    res.nil? ? default : res
  end

  def get_default(value)
    value = value.to_s
    return true if value == 'watch_anime'
    return true if value == 'last_episode'
    return true if value == 'episode_tracking'
    return true if value == 'recommendations'
    return true if value == 'images'
    return true if value == 'autoplay'
  end
end
