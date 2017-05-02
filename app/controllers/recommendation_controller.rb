class RecommendationController < ApplicationController

	def main
	end

	def create
		dubsub = recommendations_params[:dubsub]
		title = recommendations_params[:title]
		html = recommendations_params[:html]
		ref_link = recommendations_params[:ref_link]

		rec = Recommendation.new
		rec.title = title
		rec.description = html
		rec.dubbed = dubsub.to_s.strip == "true"
		rec.from_user = current_user.id
		result = rec.save ? true : false
		rec = nil if result == false

		render json: {result: rec, success: result}
	end

	private
		def recommendations_params
			params.permit(
				:dubsub,
				:title,
				:html
			)
		end

end
