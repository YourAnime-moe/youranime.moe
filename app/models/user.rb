class User < ApplicationRecord

  serialize :episodes_watched
  serialize :episode_progress_list
  serialize :settings

  has_one_attached :avatar
  has_many :user_watch_progresses

  DEFAULT_DEMO_NAME = "Demo Account"
  DEFAULT_DEMO_USERNAME = "demo"
  DEFAULT_DEMO_TOKEN = "demo"

  before_save :check_user
  has_secure_token :auth_token
  has_secure_password

  def auth_token
    return DEFAULT_DEMO_TOKEN if self.is_demo_account?
    self[:auth_token]
  end

  def username
    return DEFAULT_DEMO_USERNAME if self.is_demo_account?
    return self[:username]
  end

  def name
    return DEFAULT_DEMO_NAME if self.is_demo_account?
    self[:name]
  end

  def get_name
    return "#{username}" if self.name.nil?
    self.name
  end

  # All episodes this user is able to view
  def episodes_data(show)
    show.episodes.map do |episode|
      progress = episode.progress_info(self)
      episode.as_json.merge({
        progress: progress[:progress_info]
      })
    end
  end

  # Returns a list of episodes that have "watching progress"
  def currently_watching(limit: nil, no_thumbnails: false)
    history(limit: limit)
  end

  def history(limit: nil)
    sql = <<-SQL
      select users.*, episodes.*
      from episodes
      cross join users
      inner join user_watch_progresses progress
      on episodes.id = progress.episode_id and progress.user_id = users.id
      where users.id = ?
      and progress > 0
      limit ?;
    SQL
    limit = limit.nil? ? 100 : limit.to_i
    Episode.find_by_sql([sql, self.id, limit])
  end

  def allows_setting(what)
    return get_default(what) if self.settings.class != Hash
    is_ok(what, get_default(what))
  end

  def is_admin?
    return false if self.admin.nil?
    self.admin
  end

  def is_demo_account?
    !!self.demo
  end

  def is_activated?
    # All users should be activated by default. They will be deactivated on request.
    was_nil = self.is_activated.nil?
    self.update(is_activated: true) if was_nil
    self.is_activated
  end

  def is_demo?
    return username == "demo"
  end

  def update_settings(new_settings, save=true)
    keys = [:watch_anime, :last_episode, :episode_tracking, :recommendations, :images, :autoplay]
    if new_settings.nil? || new_settings.class != Hash
      new_settings = {
        :watch_anime => true,
        :last_episode => true,
        episode_tracking: true,
        recommendations: true,
        images: true,
        autoplay: true
      }
    end
    if self.settings.class != Hash
      self.settings = {}
    end
    keys.each do |setting_key|
      new_value = new_settings[setting_key]
      new_value = new_settings[setting_key.to_s] if new_value.nil?
      next if new_value.nil?
      if self.settings.keys.include? setting_key.to_s
        self.settings.delete setting_key.to_s
      end
      self.settings[setting_key] = new_value
    end
    save ? self.save : true
  end

  def destroy_token
    self.update_attribute(:auth_token, nil)
  end

  def as_json(options={})
    keys = [
      :username,
      :name,
      :limited,
      :google_user
    ]
    super(only: keys).tap do |hash|
      hash[:active] = is_activated?
      hash[:admin] = is_admin?
      hash[:demo] = is_demo_account?
    end
  end

  def self.find_by_token token
    self.find_by auth_token: token
  end

  def self.from_omniauth(auth)
    where(username: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.username = auth.info.email
    end
  end

  private

  def check_user
    self.episodes_watched = [] if self.episodes_watched.nil?
    self.episode_progress_list = [] if self.episode_progress_list.nil?

    if self.is_demo_account?
      found_user = User.find_by(demo: true)
      unless found_user.nil? || found_user.id == self.id
        self.errors.add "username", "\"#{found_user.username}\" is already a demo account. Only one demo account is allowed."
        throw :abort
      end
    else
      if self.username.nil? or self.username.strip.empty?
        self.errors.add "username", "cannot be empty"
        throw :abort
      end

      found_user = User.find_by(username: self.username)
      unless found_user.nil? || found_user.id == self.id
        self.errors.add "username", "\"#{self.username}\" already exists"
        throw :abort
      end
    end
  end

  def is_ok(value, default)
    res = self.settings[value]
    res = self.settings[value.to_s] if res.nil?
    res = true if res == "true"
    res = false if res == "false"
    res.nil? ? default : res
  end

  def get_default(value)
    value = value.to_s
    return true if value == "watch_anime"
    return true if value == "last_episode"
    return true if value == "episode_tracking"
    return true if value == "recommendations"
    return true if value == "images"
    return true if value == "autoplay"
  end
end
