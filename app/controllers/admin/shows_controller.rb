class Admin::ShowsController < AdminController

	def index
		set_title before: t('admin.home')
	end

	def show
		show = Show.find_by(id: params[:id])
		show = show.admin_json unless show.nil?
		respond_to do |format|
			format.json { render json: {show: show} }
		end
	end

	def update
		show = Show.find_by(id: params[:id])
		success = !show.nil?
		if show
			show.banner.attach(params[:banner])
			show = show.admin_json
		end
		respond_to do |format|
			format.json { render json: { show: show, success: success } }
		end
	end
	
end
