module Shows
  class UpdateReaction < ApplicationOperation
    LIKE_REACTION = 'like'
    DISLIKE_REACTION = 'dislike'

    REACTIONS = [LIKE_REACTION, DISLIKE_REACTION].freeze

    property! :show, accepts: Show
    property! :user, accepts: User
    property! :reaction, accepts: REACTIONS, converts: :to_s

    def execute
      update_reaction
    end

    private

    def update_reaction
      if reaction == LIKE_REACTION
        handle_reaction(:like)
      elsif reaction == DISLIKE_REACTION
        handle_reaction(:dislike)
      end
    end

    def handle_reaction(type)
      if user.send("#{type}d?", show)
        user.unreact_to!(show) && "un#{type}d"
      else
        user.send("#{type}!", show) && "#{type}d"
      end
    end
  end
end
