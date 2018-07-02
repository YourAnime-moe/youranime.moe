class Admin::ShowsController < AdminController

	def index
		@select_show = current_admin_show_id
		set_title before: t('admin.home')
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

	def update
		show = Show.find_by(id: params[:id])
		success = !show.nil?
		message = nil
		if show
			if params[:banner].class == ActionDispatch::Http::UploadedFile
				show.banner.attach(params[:banner])
			end
			show.update_attributes(show_params)
			show = show.admin_json if show
		end
		success = !show.nil?
		if success
			message = t('admin.success.updated')
		end
		respond_to do |format|
			format.json { render json: { show: show, success: success, message: message } }
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
		params.permit(
			:title,
			:alternate_title,
			:description,
			:published,
			:image_path,
			:default_path
		)
	end
	
end
