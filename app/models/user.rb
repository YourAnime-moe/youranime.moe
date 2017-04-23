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
    has_secure_token :auth_token

    def get_name
        return "'#{username}'" if self.name.nil?
        self.name
    end

    def add_episode(episode, save: true)
        p "Adding #{episode}..."
        # return nil unless self.allows_setting(:episode_tracking)
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
        p "Episode #{episode.id} was added."
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

    def get_latest_episodes(limit: 5)
        limit = 5 if limit.to_s.strip.size < 0 || limit < 0
        episodes = self.get_episodes_watched.map{|e| Episode.find(e)}.reverse
        episodes.select!{|e| e.is_published?}
        return episodes if episodes.size <= limit
        episodes[0...limit]
    end

    def has_watched_anything?
        !self.episodes_watched.nil? and !self.get_episodes_watched.empty?
    end

    def get_episode_count
        base = "You have watched "
        return base << "0 episodes." if self.get_episodes_watched.empty?
        return base << "#{self.episodes_watched.size} episodes." if self.get_episodes_watched.size > 1
        base << "one episode."
    end

    def allows_setting(what)
        return true if self.settings.class != Hash
        what = what.to_s
        is_ok(what, get_default(what))
    end

    def is_new?
        self.id.nil?
    end

    def is_admin?
        return false if self.admin.nil?
        self.admin
    end

    def update_settings(new_settings, save=true)
        if new_settings.nil?
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
        self.settings.update(new_settings)
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
            res = true if res == "true" or res.nil?
            res = false if res == "false"
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
