module Admin
  class ShowsController < ApplicationController
    def index
      @shows = Show.includes(:title_record).order('updated_at asc')
      set_title(before: 'Shows')
    end

    def show
      shows = Show.includes(:ratings, :tags, :title_record, seasons: :episodes)
      if (@show = shows.find_by(id: params[:id]))
        render('show')
      else
        redirect_to(admin_shows_path, notice: 'This show does not exist!')
      end
    end

    def process_csv
      Import::ShowsCsv.perform(
        by_author: current_user,
        file: params[:shows_data],
      )

      redirect_to admin_shows_path
    end
  end
end
