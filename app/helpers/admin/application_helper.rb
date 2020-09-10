module Admin
  module ApplicationHelper
    def boolean_tag(value, yes: :success, no: :danger, true_text: 'yes', false_text: 'no', light: false)
      value_tag((value ? true_text : false_text), colour: (value ? yes : no), light: light)
    end

    def value_tag(value, colour: 'light', light: false)
      colour = "is-#{colour}#{' is-light' if light}"
      content_tag(:span, class: "tag #{colour}") do
        value
      end
    end
  end
end