class AuthApiController < ApiController

	before_filter {
		token = params[:token]
		if token.to_s.strip.empty?
			render json: {message: "Access denied. No token was specified."}
		end
		@user = User.find_by(auth_token: token)
		if @user.nil?
			render json: {message: "Access denied. Invalid token."}
		end
	}

	def user
		render json: @user
	end

	def shows
		if shows_params.empty?
			shows = Show.all
		else
			shows = Show.find_by(shows_params)
		end
		shows = shows.to_a
		shows.select! {|show| show.is_published?}
		render json: {shows: shows}
	end

	def lastest_shows
		amount = params[:amount]
		amount = 5 if amount.to_s.strip.empty?
		amount = amount.to_i
		shows = @user.get_latest_episodes limit: amount
		render json: {shows: shows}
	end

	def news
		render json: {news: News.all}
	end

	def episodes
		if episodes_params.empty?
			episodes = Episode.all
		else
			episodes = Episode.find_by(episodes_params)
		end
		episodes = episodes.to_a
		episodes.select! {|episode| episode.is_published?}
		render json: {episodes: episodes}
	end

	def episode_path
		id = params[:id]
		episode = Episode.find_by(id: id)
		if episode.nil?
			render json: {path: nil, message: "No ID was specified."}
		else
			if episode.is_published?
				render json: {path: episode.get_path}
			else
				render json: {path: nil, message: "Episode is not published."}
			end
		end
	end

	def destroy_token
		username = @user.username
		if @user.destroy_token
			render json: {message: "Token for user #{username} was successfully destroyed."}
		else
			render json: {message: "Could not destroy token for user #{username}"}
		end
	end

	private
		def shows_params
			params.permit(
				:id,
				:show_type,
				:dubbed,
				:subbed,
				:average_run_time,
				:show_number,
				:year,
				:title,
				:altername_title,
				:published
			)
		end

		def episodes_params
			params.permit(
				:id,
				:show_id,
				:title,
				:episode_number,
				:published
			)
		end

end