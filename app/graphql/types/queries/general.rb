module Types
  module Queries
    module General
      GraphQL::Relay::ConnectionType.bidirectional_pagination = true

      def main_queue
        return nil unless current_user.present?
  
        main_queue = current_user.queues.first_or_create
        main_queue.present? ? main_queue.shows : []
      end

      def discover(limit: 4)
        shows.random.limit(limit)
      end

      def trending(limit: 4)
        shows.limit(limit)
      end

      def all_shows(**args)
        shows(**args).limit(100)
      end

      def shows_connection(**args)
        shows(**args)
      end

      def show(show_id:)
        shows.find_by(id: show_id)
      end

      def seasons(show_id:)
        ::Shows::Season.where(show_id: show_id)
      end

      def episode(id:)
        return nil unless current_user
  
        episode = Episode.find_by(id: id)
        unless current_user.admin?
          show = episode.season.show
          unless show.published?
            Rails.logger.error('The episode\'s show is not published.')
            raise 'This episode is not available at the moment.'
          end
        end
        unless episode.present?
          Rails.logger.error("Episode with id = `#{id}` was not found.")
          raise 'This episode was not found or has been removed.'
        end
  
        episode
      end

      def search_show(title:, limit: 20)
        Show.search(title, limit: limit)
      end

      protected

      def shows(**)
        scope = current_user&.admin? ? :all : :published
  
        Show.send(scope)
      end
  
      def fetch_first(args)
        first = args[:first].present? ? args[:first] : 10
        first = 100 if first > 100
  
        first
      end
    end
  end
end
