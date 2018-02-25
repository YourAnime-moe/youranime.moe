require 'json'

class AuthApiController < ApiController

	before_filter {
		token = params[:token]
		if token.to_s.strip.empty?
			render json: {message: "Access denied. No token was specified.", success: false}
		end
		@user = User.find_by(auth_token: token)
		is_admin = params[:admin] == "true"
		if @user.nil?
			render json: {
				rails_message: "Access denied. Invalid token.",
				message: "Did you login on another device?",
				show_login: true,
				show_login_message: "Re-login",
				success: false
			}
		elsif is_admin && !@user.is_admin?
			render json: {
				rails_message: "Access denied. This action requires to be an admin.",
				message: "Access denied. This action requires to be an admin.",
				show_login: true,
				show_login_message: "Re-login",
				success: false
			}
		end
		@is_admin = params[:admin] == "true"
	}

	def user
		response = @user.attributes
		response.delete "password"
		response.delete "password_digest"
		render json: {user: response, success: true}
	end

	def get_username
		id = params[:id]
		user = User.find_by id: id
		if user.nil?
			render json: {
				success: false,
				message: "User with id #{id} does not exist"
			}; return
		end
		render json: {
			success: true,
			username: user.username,
			current_user: User.find_by(auth_token: params[:token]) == user
		}
	end

	def shows
		if shows_params.empty? || shows_params[:get_host]
			results = Show.all.select {|show| show.is_anime? && !show.get_title.nil?}
			results = results.to_a.sort_by(&:get_title)
			results.select! {|show| show.is_published? || @is_admin}
		else
			results = Show.find_by(shows_params) || {}
			json = results.to_json
			my_hash = JSON.parse json
			my_hash[:available_episodes] = results.episodes.size if results != {}
			my_hash[:total_episodes] = results.all_episodes.size if results != {}
			results = my_hash
		end
		res = {shows: results, success: !results.empty?}
		res[:get_host] = Config.main_host if shows_params[:get_host] == "true"
		render json: res
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
		elsif episodes_params.keys.include? "show_id"
			episodes = []
			show = Show.find_by(id: episodes_params[:show_id])
			unless show.nil?
				show.episodes.each do |ep|
					result = ep.to_json
					result = JSON.parse result
					pv = ep.previous
					nx = ep.next
					result[:calc_next_id] = nx.id if nx
					result[:calc_prev_id] = pv.id if pv
					result[:is_published] = ep.is_published?
					result[:image_path] = ep.get_image_path
					result[:watched] = @user.has_watched? ep
					result[:path] = ep.get_path
					episodes.push result
				end
			end
		else
			episodes = Episode.find_by(episodes_params)
            if episodes.nil?
                episodes = {}
            else
                result = episodes.to_json
                result = JSON.parse result
                pv = episodes.previous
                nx = episodes.next
                result[:calc_next_id] = nx.id if nx
                result[:calc_prev_id] = pv.id if pv
                result[:is_published] = episodes.is_published?
				result[:image_path] = episodes.get_image_path
				result[:path] = episodes.get_path
                episodes = result
            end
		end
		unless episodes.class == Episode or episodes.class == Hash
			episodes = episodes.to_a
			begin
				episodes.select! {|episode| episode.is_published? || @is_admin}
			rescue NoMethodError => e
				episodes.select! {|episode| episode[:is_published] == true}
			end
		end
		render json: {episodes: episodes, success: !episodes.empty?}
	end

	def add_episode
		id = episodes_params[:id]
		episode = Episode.find_by(id: id)
		if episode
			render json: {success: @user.add_episode(episode, save: true)}
		else
			render json: {success: false, message: "Episode id #{id} not found."}
		end
	end

	def episode_path
		id = params[:id]
		episode = Episode.find_by(id: id)
		if episode.nil?
			render json: {path: nil, message: "No ID was specified.", success: false}
		else
			if episode.is_published?
				render json: {path: episode.get_new_path, success: true}
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
				:published,
				:get_host
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
