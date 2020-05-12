module Shows
  class Recommend < ApplicationOperation
    property! :user
    property :limit, default: nil

    def execute
      recommend_shows
    end

    private

    def recommend_shows
      other_users = User.where.not(id: user.id)
      recommended = Hash.new(0)
      rated_shows = user.rated_shows

      other_users.each do |other_user|
        other_rated_shows = other_user.rated_shows
        common_movies = other_rated_shows & rated_shows
        next if other_rated_shows.empty?

        weight = common_movies.size.to_f / other_rated_shows.size
        recommendations = other_rated_shows - common_movies

        recommendations.each do |movie|
          recommended[movie] += weight
        end
      end

      recommended.sort_by { |_, v| v }.reverse
      Show.where(id: recommended.map { |k, _| k }).limit(limit)
    end
  end
end