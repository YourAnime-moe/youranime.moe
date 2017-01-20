class Episode < ActiveRecord::Base

    before_save {
        !self.show_id.nil?
    }

    def number
        return 1 if self.class.first.id == self.id
        result = 1
        self.class.all.each do |ep|
            break if ep.id == self.id
            result += 1
        end
        result
    end

    def show
        return @show unless @show.nil?
        return nil if self.show_id.nil?
        @show = Show.find(self.show_id)
    end

    def get_url_safe_title
        "episode-#{self.episode_number}"
    end

    def is_published?
        return false if self.published.nil?
        self.published
    end

    def previous
        return @previous unless @previous.nil?
        #@previous = Episode.find(self.previous_id) unless self.previous_id.nil?
        #return @previous unless @previous.nil?
        return nil if self.episode_number == 1
        number = self.episode_number-1
        while true
            p "Looking at #{number}..."
            @previous = Episode.find_by(show_id: self.show_id, episode_number: number)
            return nil if @previous.nil?
            return @previous if @previous.is_published?
            number -= 1
        end
    end
    
    def next
        return @next unless @next.nil?
        #@next = Episode.find(self.next_id) unless self.next_id.nil?
        #return @next unless @next.nil?
        number = self.episode_number + 1
        until false
            p "Looking at #{number}"
            @next = Episode.find_by(show_id: self.show_id, episode_number: number)
            return nil if @next.nil?
            return @next if @next.is_published?
            number += 1
        end
        @next = Episode.find_by(show_id: self.show_id, episode_number: (self.episode_number+1))
    end

    def get_path_extension
        return nil if self.path.nil?
        parts = self.path.split "."

        # Only accept the last part, don't accept multiple extensions for videos
        parts[parts.size-1]
    end
    
    def has_previous?
        !self.previous.nil?
    end

    def has_next?
        !self.next.nil?
    end

    def get_path
        return self.path if self.path.nil? or self.path.start_with? "http"
        Config.path self.path
    end

    def was_watched_by?(user)
        return false if user.episodes_watched.nil? or user.episodes_watched.empty?
        !user.episodes_watched.select { |id| id == self.id }.empty?
    end

    def self.instances
        [:title, :episode_number]
    end

end
