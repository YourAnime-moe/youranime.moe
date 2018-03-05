class Episode < ActiveRecord::Base

    serialize :comments

    include Navigatable

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

    def is_published?
        return false if self.published.nil? && !self.show.nil?
        return self.published if self.show.nil?
        self.show.is_published? && self.published
    end

    def get_path_extension
        return nil if self.path.nil?
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

    def get_path(token=nil)
        return self.path if self.path.nil? or self.path.start_with? "http"
        res = Config.path self.path
        return res if token.nil?
        res + '?token=' + token
    end

    def get_new_path
        return self.path if self.path.nil? or self.path.start_with? "http"
        video_path = self.path
        parts = video_path.split '/'
        return nil if parts.size <= 2

        # Get the general information
        filename = parts[parts.size-1]
        show_name = parts[parts.size-2]

        # Get the episiode number and extension
        filename_parts = filename.split '.'
        ext = filename_parts[filename_parts.size-1]
        filename_name = filename_parts[0].split 'ep'
        ep_num = filename_name[1] || self.episode_number

        Config.path "videos?show=#{show_name}&episode=#{ep_num}&format=#{ext}&video=true"
    end

    def get_image_path(token=nil, ext: 'jpg')
        video_path = self.get_path
        parts = video_path.split('/')
        filename = parts[parts.size-1]
        fs = filename.split '.'
        fs[1] = ext.to_s
        filename = fs.join '.'
        parts[parts.size-1] = filename
        path = parts.join '/'
        return path if token.nil?
        path + "?token=" + token
    end

    def get_new_image_path(ext: 'jpg')
        return self.path if self.path.nil? or self.path.start_with? "http"
        video_path = self.path
        parts = video_path.split '/'
        return nil if parts.size <= 2

        # Get the general information
        filename = parts[parts.size-1]
        show_name = parts[parts.size-2]

        # Get the episiode number and extension
        filename_parts = filename.split '.'
        filename_name = filename_parts[0].split 'ep'
        ep_num = filename_name[1] || self.episode_number

        Config.path "videos?show=#{show_name}&episode=#{ep_num}&format=#{ext}"
    end

    def get_subtitle_path(ext: 'vtt')
        return nil if !self.show.nil? && self.show.dubbed
        get_image_path ext: ext
    end

    def get_new_subtitle_path(ext: 'vtt')
        path = get_new_image_path ext: ext
        path + "&subtitles=true"
    end

    def has_subs?
        self.show.subbed ? true : false
    end

    def was_watched_by?(user)
        return false if user.episodes_watched.nil? or user.episodes_watched.empty?
        !user.episodes_watched.select { |id| id == self.id }.empty?
    end

    def has_watched_mark?
        !get_watched_mark.nil?
    end

    def get_watched_mark
        80
    end

    def progress_info user
        info = {
            user: user.id,
            episode: self.id,
            progress_info: nil
        }
        return info if user.episode_progress_list.nil? || user.episode_progress_list.empty?
        info[:progress_info] = user.episode_progress_list.select{|chunk| chunk[:id] == self.id}[0]
        info[:found] = !info[:progress_info].nil?
        info
    end

    def add_comment(comment)
        unless comment.instance_of? Hash
            return {success: false, message: "Invalid data was received."}
        else
            if self.comments.nil?
                self.comments = []
            end
            self.comments.push comment
            save = self.save
            message = save ? 'Comment was received.' : 'There was an error while saving the comment.'
            return {success: save, message: message}
        end
    end

    def get_comments(time: true, usernames: false)
        list = []
        return list if self.comments.nil?
        self.comments.each do |comment|
            next unless comment.instance_of? Hash
            new_comment = {text: comment[:text]}
            if time
                new_comment[:time] = Utils.get_date_from_time(Time.parse(comment[:time].to_s).getlocal)
            end
            if usernames
                user = User.find_by(id: comment[:user_id])
                if user.nil?
                    username = "User ##{comment[:user_id]}"
                else
                    username = user.username
                end
                new_comment[:user_id] = username
            end
            new_comment[:time] = comment[:time] if new_comment[:time].nil?
            new_comment[:user_id] = comment[:user_id] if new_comment[:user_id].nil?
            list.push new_comment
        end
        list
    end

    def self.instances
        [:title, :episode_number]
    end

    def self.all_published
        self.all.select{|e| e.is_published?}
    end

end
