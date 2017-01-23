class Show < ActiveRecord::Base

    include Navigatable

    before_save {
        # Make the show is at least one of dubbed or subbed.
        if self.dubbed.nil? and self.subbed.nil?
            # Default to...
            self.subbed = true
        end
    }

    def dub_sub_info
        return "Dubbed and Subbed" if self.dubbed and self.subbed;
        return "Dubbed" if self.dubbed
        "Subbed"
    end

    def get_title
        return self.title if self.alternate_title.to_s.empty?
        self.alternate_title
    end

    def prequel
        return nil if self.id == Show.first.id
        shows = Show.all.select { |e| e.title == self.title }
        (1...shows.size).each do |current|
            found = shows[current-1]
            return found if shows[current].id == self.id && found.title == self.title
        end
        nil
    end

    def sequel
        return nil if self.id == Show.last.id
        shows = Show.all.select { |e| e.title == self.title }
        (0...shows.size).each do |current|
            break if current == shows.size-1
            found = shows[current+1]
            return found if shows[current].id == self.id && found.title == self.title
        end
        nil
    end

    def episodes(from: nil)
        return @episodes unless @episodes.nil?
        return nil if self.id.nil?
        results = Episode.all.select{ |e| e.show_id == self.id && e.is_published? }
        @episodes = results.sort_by(&:episode_number)
        return @episodes if from.nil?
        from = from.episode_number
        return @episodes if from == 1 or from == @episodes.size-1
        parts = @episodes.partition {|episode| episode.episode_number >= from}
        result = parts[0]
        result += parts[1]
    end

    def split_episodes(sort_by: 4)
        episodes = self.episodes
        return nil if episodes.nil?
        episodes = episodes.to_a unless episodes.instance_of? Array
        episodes.each_slice(sort_by).to_a
    end

    def has_starring_info?
        self.starring.to_s.strip.size > 0
    end

    def discloses_average_run_time?
        !self.average_run_time.nil?
    end

    def is_published?
        return false if self.published.nil?
        self.published
    end

    def has_episodes?
        !self.episodes.empty?
    end

    def get_url_safe_title
        return nil if self.title.nil?
        if self.show_number.nil?
            sn = ""
        else
            sn = "-#{self.show_number}"
        end
        "#{self.title.downcase}#{sn}"
    end

    def get_image_path
        return self.image_path if self.image_path.to_s.strip.empty? or self.image_path.start_with? "http"
        Config.path self.image_path
    end

    def has_image?
        self.image_path.to_s.strip.size > 0
    end

    def has_description?
        self.description.to_s.strip.size > 0
    end

    def get_description(limit=50)
        return nil unless self.has_description?
        if limit >= self.description.size
            limit = self.description.size - 1
        end
        self.description[0, limit] + "..."
    end

    def self.get(title: nil, show_number: nil)
        return nil if title.nil? or show_number.nil?
        title = title.capitalize
        self.find_by(title: title, show_number: show_number)
    end

    def self.instances
        [:get_title]
    end

    def self.lastest(current_user)
        episodes = current_user.get_episodes_watched
        episodes = episodes.map{|e| Episode.find e}.reverse
        shows = []
        episodes.each do |ep|
            next unless ep.is_published?
            show = ep.show
            next unless show.is_published?
            next unless show.has_image?
            shows.push show unless shows.include? show
            break if shows.size >= 5
        end
        shows
    end

end
