class Admin::EpisodesController < AdminController

	def create
		episode = Show::Episode.find_by(episode_number: params[:episode_number], show_id: params[:show_id])
		if episode
			success = episode.update_attributes(
				title: params[:title]
			)
		else
			episode = Show::Episode.new(episodes_params)
			success = episode.save
		end
		if success
			episode.thumbnail.attach(params[:thumbnail]) if params[:thumbnail].class == ActionDispatch::Http::UploadedFile
			episode.video.attach(params[:video]) if params[:video].class == ActionDispatch::Http::UploadedFile
		end

		render json: { success: success, number: params[:episode_number] }
	end

	def index
    @episodes = Show::Episode.all.order('id desc')
    @episodes = @episodes.paginate(page: params[:page])
    set_title before: 'Manage episodes'
	end

	def update
		episode = Show::Episode.find_by(id: params[:id])
		success = false
		unless episode.nil?
			episode.update_attributes(episodes_params)
			if params[:video].class == ActionDispatch::Http::UploadedFile
				episode.video.attach(params[:video])
				success = true
			end
			if params[:thumbnail].class == ActionDispatch::Http::UploadedFile
				episode.thumbnail.attach(params[:thumbnail])
				success = true
			end
		end
		render json: { success: success }
	end

	private

	def episodes_params
		params.permit(
			:title,
			:published,
			:episode_number,
			:show_id
		)
	end

end
