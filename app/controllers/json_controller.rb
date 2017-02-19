class JsonController < ApplicationController

    def search
        instance = params[:instance]
        keyword = params[:keyword]
        limit = params[:limit]
        sort_by = params[:sort_by]

        klass = get_class_from_instance_tag(instance)
        if klass.nil?
            render json: {message: "Invalid instance.", response: "Class was no found.", success: false}
            return
        end

        begin
            list = klass.all
        rescue NameError => e
            render json: {message: "Invalid instance.", response: e.message, success: false}
            return
        end

        begin
            res = Utils.search(keyword, list, get_instances_from_class(klass), limit: limit, sort_by: sort_by)
        rescue NameError => e
            render json: {message: "Invalid data entered", response: e.message, success: false}
            return
        end

        render json: {message: "Success", success: true, response: res}
    end

    def find_show
        if params[:given_title]
            Show.all.each do |show|
                if show.get_title.downcase == params[:given_title].downcase
                    @show = show
                    break
                end
                if show.title.downcase == params[:given_title].downcase
                    @show = show
                end
            end
        end
        if @show
            json = {id: @show.id}
        else
            json = {err: "Show was not found. We'll fix this as soon as possible"}
        end
        render json: json
    end

    def episode_get_comments
        id = params[:id]
        if id.nil?
            render json: {err: 'Episode id was not specified.'}
        elsif Episode.find_by(id: id).nil?
            render json: {err: 'Episode was not found.'}
        else
            episode = Episode.find(id)
            if params[:usernames]
                usernames = params[:usernames].strip.downcase == 'true'
            else
                usernames = false
            end
            comments = episode.get_comments(usernames: usernames)
            render json: {instance: episode, comments: comments.reverse}
        end
    end

    def episode_add_comment
        id = params[:id]
        if id.nil?
            render json: {err: 'Episode id was not specified.'}
        elsif Episode.find_by(id: id).nil?
            render json: {err: 'Episode was not found.'}
        else
            e = Episode.find(id)
            if params[:comments].to_s.strip.size == 0
                render json: {err: 'No text was received.'}
            else
                comment = {text: params[:comments], user_id: current_user.id, time: Time.now}
                result = e.add_comment(comment)
                comments = e.comments || []
                render json: {message: result[:message], success: result[:success], comments: comments, instance: e}
            end
        end
    end

    def set_watched
        @episode = Episode.find(params[:id])
        render json: {message: "sucess", success: current_user.add_episode(@episode)}
    end

    def get_next_episode_id
        episode = Episode.find_by(id: params[:id])
        if episode.nil?
            render json: {success: false}
        else
            next_episode = episode.next
            next_id = next_episode.nil? ? nil : next_episode.id
            render json: {success: true, next_id: next_id}
        end
    end

    private
        def get_class_from_instance_tag(tag)
            tag = tag.to_s
            return nil if tag.strip.empty?
            return Show if tag == "show" or tag == "shows"
            return Episode if tag == "episode" or tag == "episodes"
        end

        def get_instances_from_class(klass)
            klass.instances
        end
end
