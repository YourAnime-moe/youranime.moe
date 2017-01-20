class User < ActiveRecord::Base

    serialize :episodes_watched
    serialize :settings

    before_save {
        self.episodes_watched = [] if self.episodes_watched.nil?

        if self.username.nil? or self.username.strip.empty?
            false
        end

        user = User.find_by(username: self.username)
        unless user.nil?
            false if user.id != self.id
        end
    }

    has_secure_password

    def get_name
        return "'#{username}'" if self.name.nil?
        self.name
    end

    def add_episode(episode, save: true)
        return nil unless self.allows_setting(:episode_tracking)
        return false unless episode.class == Episode or episode.class == Fixnum
        if episode.instance_of? Fixnum
            episode = Episode.find_by(id: episode)
            return false if episode.nil?
        end
        self.episodes_watched = [] if self.episodes_watched.nil?
        if self.episodes_watched.include? episode.id
            self.episodes_watched.delete(episode.id)
        end
        self.episodes_watched.push episode.id
        save ? self.save : true
    end

    def get_episodes_watched(as_is: false)
        return nil unless self.episodes_watched.nil? or self.episodes_watched.class == Array
        return [] if self.episodes_watched.nil?
        res = self.episodes_watched
        return res if as_is
        res.reject! { |episode_id| Episode.find_by(id: episode_id).nil? }
        self.update_attribute(:episodes_watched, res) ? res : nil
    end

    def has_watched_anything?
        !self.episodes_watched.nil? and !self.get_episodes_watched.empty?
    end

    def get_episode_count
        base = "You have watched "
        return base << "0 episodes" if self.get_episodes_watched.empty?
        return base << "#{self.episodes_watched.size} episodes" if self.get_episodes_watched.size > 1
        base << "one episode."
    end

    def allows_setting(what)
        return true if self.settings.class != Hash
        what = what.to_s
        is_ok(what, get_default(what))
    end

    private
        def is_ok(value, default)
            res = self.settings[value]
            res = true if res == "true"
            res = false if res == "false" or res.nil?
            res
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
