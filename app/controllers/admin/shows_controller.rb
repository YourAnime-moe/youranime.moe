class Admin::ShowsController < AdminController

	def index
    title_column = "fr_title" if I18n.locale == :fr
    title_column = "jp_title" if I18n.locale == :jp
    title_column = "title" if title_column.nil?

		@shows = Show.paginate(page: params[:page])
        .order('published desc')
        .order("#{title_column} asc")
    @shows_parts = @shows.each_slice(4)
    respond_to do |format|
      format.html
      format.js
    end
	end

	def show
		show = Show.find_by(id: params[:id])
		unless show.nil?
			set_current_admin_show_id(show.id)
			show = show.admin_json
		end
		respond_to do |format|
			format.json { render json: {show: show} }
		end
	end

	def edit
		@show = Show.find_by(id: params[:id])
	end

	def update
		show = Show.find_by(id: params[:id])
		success = !show.nil?
		message = nil
		if show
			if show_params[:banner].class == ActionDispatch::Http::UploadedFile
				io = show_params[:banner].tempfile
				path = show.image_path

				show.banner.attach(io: io, filename: path)
			end

      tags = params[:show][:tags].split(' ').map{|tag| tag.to_sym}
      show.tags = []
      tags.each {|tag| show.add_tag(tag)}
      p tags
      p show.tags

      show.title = params[:show][:title] if params[:show][:title]
      show.description = params[:show][:description] if params[:show][:description]

			show.update_attributes(show_params)
		end
		success = !show.nil?
		if success
			message = t('admin.success.updated')
		end
		respond_to do |format|
			format.json { render json: { show: show, id: params[:id], success: success, message: message } }
      format.html {
        if success
          redirect_to(edit_admin_show_path(show), notice: 'The show was successfully updated!')
        else
          redirect_to(edit_admin_show_path(show), alert: 'There was an error while updating the show')
        end
      }
		end
	end

	def publish
		show = Show.find_by(id: params[:id])
		message = ''

		published = params[:published] == 'true'
		show = show.update_attributes(published: published).nil? ? nil : show
		message_key = published ? 'admin.success.published' : 'admin.success.un-published'
		message = t(message_key) if show

		respond_to do |format|
			format.json { render json: { success: !show.nil?, message: message, published: (show.is_published? if show) } }
		end
	end

	private

	def show_params
		params.require(:show).permit(
			:published,
			:image_path,
      :dubbed, :subbed
		)
	end

end
