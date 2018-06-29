class User < ActiveRecord::Base

    serialize :episodes_watched
    serialize :episode_progress_list
    serialize :settings

    before_save {
        self.episodes_watched = [] if self.episodes_watched.nil?
        self.episode_progress_list = [] if self.episode_progress_list.nil?

        if self.username.nil? or self.username.strip.empty?
            self.errors.add "username", "cannot be empty"
            throw :abort
        end

        found_user = User.find_by(username: self.username)
        unless found_user.nil? || found_user.id == self.id
            self.errors.add "username", "\"#{self.username}\" already exists"
            throw :abort
        end

        if self.is_demo_account?
            found_user = User.find_by(demo: true)
            unless found_user.nil? || found_user.id == self.id
                self.errors.add "username", "\"#{found_user.username}\" is already a demo account. Only one demo account is allowed."
                throw :abort
            end
        end
    }

    has_secure_password
    has_secure_token :auth_token

    def auth_token
        return self[:auth_token] unless self.is_demo_account?
        "demo"
    end

    def username
        return self[:username] unless self.is_demo_account?
        "demo"
    end

    def name
        return self[:name] unless self.is_demo_account?
        "Demo Account"
    end

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

    def update_episode_progress(episode, progress)
        progress = progress.to_i
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
        if progress == 0
            warn "Skipping this episode (progress == 0)"
            return true
        end
        present = false
        self.episode_progress_list = [] if self.episode_progress_list.nil?
        self.episode_progress_list.each do |item|
            if item[:id] == episode.id
                item[:progress] = progress
                present = true
                break
            end
        end
        unless present
            self.episode_progress_list.push({id: episode.id, progress: progress})
        end
        result = self.save
        unless result
            warn "Could not update the episode progress: #{self.errors.to_a}"
        end
        if progress >= episode.get_watched_mark
            result = result && self.add_episode(episode, save: true)
            unless result
                warn "Could not update the episode progress by setting episode as watched: #{self.errors.to_a}"
            end
        end
        result
    end

    # Returns a list of episodes that have "watching progress"
    def currently_watching(limit: nil)
        return [] if self.episode_progress_list.blank?
        res = self.episode_progress_list.map{|progress| Episode.find_by(id: progress[:id])}.reject{|episode| episode.nil?}
        self.get_latest_episodes(limit: limit).each do |episode|
            res << episode unless res.include? episode
        end
        res.reverse!
        if limit
            limit = 4 if limit < 1
            res = res[0..limit-1]
        end
        res = res.select{|e| e.has_thumbnail?}
        return res || []
    end

    def get_episodes_watched(as_is: false)
        return nil unless self.episodes_watched.nil? || self.episodes_watched.class == Array
        return [] if self.episodes_watched.nil?
        res = self.episodes_watched
        return res if as_is
        res.reject! { |episode_id| Episode.find_by(id: episode_id).nil? }
        res.select! { |episode_id| Episode.find(episode_id).is_published? }
        res
        # self.update_attribute(:episodes_watched, res) ? res : nil
    end

    def get_latest_episodes(limit: 5)
        limit = 5 if limit.to_s.strip.size < 0 || limit < 0
        p "Episodes: #{self.get_episodes_watched(as_is: false).nil?}"
        episodes = self.get_episodes_watched.map{|e| Episode.find(e)}.reverse
        episodes.select!{|e| e.is_published?}
        p "Episodes: #{episodes_watched}"
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

    def can_autoplay?
        allows_setting :autoplay
    end

    def is_new?
        self.id.nil?
    end

    def is_admin?
        return false if self.admin.nil?
        self.admin
    end

    def is_demo_account?
        return false if self.demo.nil?
        self.demo
    end

    def set_demo
        self.update_attributes demo: true
    end

    def unset_demo
        self.update_attributes demo: false
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

    def random_episode_selection(amount_watched: 5, amount_not_watched: 5, current_episode: nil)
        episodes = []
        total_size = amount_watched + amount_not_watched
        return [] if total_size == 0

        if amount_watched > 0
            episodes << self.get_episodes_watched(as_is: true)
            if episodes.size > amount_watched
                episodes.shuffle![0..amount_watched-1]
            elsif episodes.size < amount_watched
                amount_not_watched += (amount_watched - episodes.size)
            end
        end
        if amount_not_watched > 0
            (0..amount_not_watched-1).each do
                ind = rand(Episode.last.id)
                episode = nil
                while true
                    episode = Episode.find_by(id: ind)
                    break unless episode.nil? || !episode.is_published?
                    ind = rand(Episode.last.id) + 1
                end
                episodes << ind
            end
        end
        episodes.shuffle
            .map{|id| Episode.find_by(id: id)}
            .reject{|nil_ep| nil_ep.nil?}
            .reject{|is_current| is_current == current_episode}
            .uniq
    end

    def self.types
        [
            ["Regular user", false],
            ["Administrator", true]
        ]
    end

    def self.find_by_token token
        user = self.find_by auth_token: token
        return user unless user.nil?
        self.all.each do |u|
            return u if u.auth_token == token
        end
        nil
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
            return true if value == "autoplay"
        end
end
