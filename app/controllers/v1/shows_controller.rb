module V1
  class ShowsController < BaseController
    def index
      shows = Show.published.paginate(
        page: params[:page],
        per_page: per_page(default: 10),
      )

      render json: { shows: shows, meta: { per_page: per_page(default: 10) } }
    end

    def per_page(default:)
      per_page = params[:limit].to_i
      per_page = default if per_page.zero?
      per_page <= Show.per_page ? per_page : Show.per_page
    end
  end
end
