class User < ActiveRecord::Base

    serialize :episodes_watched
    serialize :settings

    before_save {
        self.episodes_watched = [] if self.episodes_watched.nil?

        if self.username.nil? or self.username.strip.empty?
            self.errors.add "username", "cannot be empty"
            throw :abort
        end

        found_user = User.find_by(username: self.username)
        unless found_user.nil? || found_user.id == self.id
            self.errors.add "username", "\"#{self.username}\" already exists"
            throw :abort
        end

    }

    has_secure_password
    has_secure_token :auth_token

    def get_name
        return "#{username}" if self.name.nil?
        self.name
    end

    def add_episode(episode, save: true)
        unless self.allows_setting(:episode_tracking)
            p "Not adding episode because user settings deny this action"
            return nil
        end
        unless episode.class == Episode || episode.class == Integer
            return false 
        end
        if episode.instance_of? Integer
            episode = Episode.find_by(id: episode)
            return false if episode.nil?
        end
        if self.episodes_watched.include? episode.id
            self.episodes_watched.delete(episode.id)
        end
        self.episodes_watched.push episode.id
        result = save ? self.save : true
        unless result
            p "Could not save user: #{self.errors.to_a}"
        end
        result
    end

    def get_episodes_watched(as_is: false)
        return nil unless self.episodes_watched.nil? || self.episodes_watched.class == Array
        return [] if self.episodes_watched.nil?
        res = self.episodes_watched
        return res if as_is
        res.reject! { |episode_id| Episode.find_by(id: episode_id).nil? }
        res.select! { |episode_id| Episode.find(episode_id).is_published? }
        self.update_attribute(:episodes_watched, res) ? res : nil
    end

    def get_latest_episodes(limit: 5)
        limit = 5 if limit.to_s.strip.size < 0 || limit < 0
        episodes = self.get_episodes_watched.map{|e| Episode.find(e)}.reverse
        episodes.select!{|e| e.is_published?}
        return episodes if episodes.size <= limit
        episodes[0...limit]
    end

    def has_watched_anything?
        !self.episodes_watched.nil? && !self.get_episodes_watched.empty?
    end

    def has_watched?(episode)
        if episode.class == Integer
            episode = Episode.find_by id: episode
        end
        return nil if episode.nil?
        self.get_episodes_watched(:as_is => true).include? episode.id
    end

    def get_episode_count
        base = "You have watched "
        return base << "0 episodes." if self.get_episodes_watched.empty?
        return base << "#{self.episodes_watched.size} episodes." if self.get_episodes_watched.size > 1
        base << "one episode."
    end

    def allows_setting(what)
        return get_default(what) if self.settings.class != Hash
        is_ok(what, get_default(what))
    end

    def is_new?
        self.id.nil?
    end

    def is_admin?
        return false if self.admin.nil?
        self.admin
    end

    def is_activated?
        # All users should be activated by default. They will be deactivated on request.
        was_nil = self.is_activated.nil?
        self.activate if was_nil
        self.save if was_nil
        self.is_activated
    end

    def is_demo?
        return username == "demo"
    end

    def activate
        (self.is_activated = true) && save
    end

    def deactivate
        !(self.is_activated = false) && save
    end

    def update_settings(new_settings, save=true)
        keys = [:watch_anime, :last_episode, :episode_tracking, :recommendations, :images]
        if new_settings.nil? || new_settings.class != Hash
            new_settings = {
                :watch_anime => true,
                :last_episode => true,
                episode_tracking: true,
                recommendations: true,
                images: true
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

    def self.types
        [
            ["Regular user", false],
            ["Administrator", true]
        ]
    end

    private
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
        end
end
