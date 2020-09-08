module Admin
  module ApplicationHelper
    def boolean_tag(value, yes: :success, no: :danger, true_text: 'yes', false_text: 'no')
      value_tag((value ? true_text : false_text), colour: (value ? yes : no))
    end

    def value_tag(value, colour: 'light')
      colour = "is-#{colour}"
      content_tag(:span, class: "tag #{colour}") do
        value
      end
    end
  end
end