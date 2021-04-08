# frozen_string_literal: true
module Home
  class TopComingSoonCategory < Home::BaseCategory
    def title_template
      "categories.top_coming_soon.title"
    end

    def enabled?
      true
    end
  end
end
