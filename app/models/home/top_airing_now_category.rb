# frozen_string_literal: true
module Home
  class TopAiringNowCategory < Home::BaseCategory
    def title_template
      "categories.top_airing_now.title"
    end

    def enabled?
      true
    end
  end
end
