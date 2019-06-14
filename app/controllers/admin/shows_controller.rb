class Admin::ShowsController < AdminController

	def index
    title_column = "fr_title" if I18n.locale == :fr
    title_column = "jp_title" if I18n.locale == :jp
    title_column = "en_title" if I18n.locale == :en
    title_column = "roman_title" if title_column.nil?

		@shows = Show.ordered.paginate(page: params[:page])
        .order('published desc')
        .order("#{title_column} asc")
    @shows_parts = @shows.each_slice(4)
    respond_to do |format|
      format.html { set_title(before: t('sidebar.admin.manage.shows')) }
      format.js
    end
	end

	def new
		@show = Show.new(published: true)
		set_title before: 'New show'
	end

	def create
		@show = Show.new(show_params)
		if @show.save
			redirect_to edit_admin_show_path(@show), notice: "This show was successfully created!"
		else
			p @show.errors_string('There was an error while updating the show')
			set_title before: 'New show', after: 'There was an error while creating the show'
			render 'new', alert: @show.errors_string('There was an error while creating the show')
		end
	end

	def edit
		@show = Show.find_by(id: params[:id])
    if @show
      set_title before: @show.title
    else
      redirect_to admin_shows_path
    end
	end

	def update
		show = Show.find(params[:id])

		if show_params[:banner].class == ActionDispatch::Http::UploadedFile
			io = show_params[:banner].tempfile
			path = show.image_path || show_params[:banner].original_filename
			show.banner.attach(io: io, filename: path)
		end

		tags = show_params[:tags].split(' ').map{|tag| tag.to_sym}
		show.tags = []
		tags.each {|tag| show.add_tag(tag)}

		if show.update(show_params)
			redirect_to(edit_admin_show_path(show), notice: 'The show was successfully updated!!')
		else
			redirect_to(edit_admin_show_path(show), alert: show.errors_string('There was an error while updating the show'))
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
			format.json { render json: { success: !show.nil?, message: message, published: (show.published? if show) } }
		end
	end

	private

	def show_params
		params.require(:show).permit(
			:published,
			:image_path,
      :dubbed, :subbed,
      :banner,
			:en_title,
			:jp_title,
			:fr_title,
			:roman_title,
			:alternate_title,
			:en_description,
			:jp_description,
			:fr_description,
			:tags
		)
	end

end
