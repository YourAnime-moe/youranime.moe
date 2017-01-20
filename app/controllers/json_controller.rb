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
