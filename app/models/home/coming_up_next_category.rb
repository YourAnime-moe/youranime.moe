# frozen_string_literal: true
module Home
  class ComingUpNextCategory < Home::BaseCategory
    def title_template
      "categories.coming_up_next.title"
    end

    def title_params
      { country: context[:country] }
    end

    def enabled?
      true
    end
  end
end
