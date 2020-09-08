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
      upload = Upload.create(upload_type: 'show-csv', user: current_user)
      upload.attachment.attach(params[:shows_data])

      ImportShowsCsvJob.perform_later(upload)

      redirect_to admin_shows_path
    end
  end
end
