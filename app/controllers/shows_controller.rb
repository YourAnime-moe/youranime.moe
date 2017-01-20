class ShowsController < ApplicationController

    def view
        if params[:view] == 'all'
            view_all
            return
        end
        if params[:id]
            @show = Show.find_by(id: params[:id])
            if @show
                render 'view'
            else
                flash[:danger] = "This show was not found. Please try again."
                redirect_to '/'
            end
            return
        end
        title = params[:title]
        show_number = params[:showNumber]
        if show_number.nil?
            show_number = params[:show_number]
        end
        if title.nil? or show_number.nil?
            @shows = Show.all
            render 'view_all'; return
        end
        Show.all.each do |show|
            if show.title = title and show.show_number.to_s == show_number
                @show = show; break
            end
        end
        if @show.nil?
            flash[:danger] = "Sorry, no show using the given parameters was not found. Please try again."
            redirect_to '/'; return
        end
        p @show
    end

    def view_all
        @shows = Show.all
    end

end
