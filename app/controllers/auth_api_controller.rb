class AuthApiController < ApiController

	before_filter {
		token = params[:token]
		if token.to_s.strip.empty?
			render json: {message: "Access denied. No token was specified.", success: false}
		end
		@user = User.find_by(auth_token: token)
		if @user.nil?
			render json: {
				rails_message: "Access denied. Invalid token.",
				message: "Did you login on another device?",
				show_login: true,
				show_login_message: "Re-login",
				success: false
			}
		end
	}

	def user
		render json: {user: @user, success: true}
	end

	def shows
		if shows_params.empty?
			shows = Show.all
		else
			shows = Show.find_by(shows_params)
		end
		shows = shows.to_a.sort_by(&:get_title)
		shows.select! {|show| show.is_published?}
		render json: {shows: shows, success: true}
	end

	def latest_shows
		amount = params[:amount]
		amount = 5 if amount.to_s.strip.empty?
		amount = amount.to_i
		shows = Show.lastest @user, limit: amount
		render json: {shows: shows, success: true}
	end

	def news
		render json: {news: News.all, success: true}
	end

	def episodes
		if episodes_params.empty?
			episodes = Episode.all
		else
			episodes = Episode.find_by(episodes_params)
		end
		episodes = episodes.to_a
		episodes.select! {|episode| episode.is_published?}
		render json: {episodes: episodes, success: true}
	end

	def episode_path
		id = params[:id]
		episode = Episode.find_by(id: id)
		if episode.nil?
			render json: {path: nil, message: "No ID was specified.", success: false}
		else
			if episode.is_published?
				render json: {path: episode.get_path, success: true}
			else
				render json: {path: nil, message: "Episode is not published.", success: false}
			end
		end
	end

	def destroy_token
		username = @user.username
		if @user.destroy_token
			render json: {message: "Token for user #{username} was successfully destroyed.", success: true}
		else
			render json: {message: "Could not destroy token for user #{username}", success: false}
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