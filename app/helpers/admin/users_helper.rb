# frozen_string_literal: true

module Admin
  module UsersHelper
    include ::ApplicationHelper
    include ::UsersHelper

    USER_TYPES_MAP = {
      google: 'Google User',
      misete: 'Misete User',
      regular: 'Regular',
      admin: 'Admin',
    }.with_indifferent_access.freeze

    def user_color(user)
      content_tag(:span, class: "tag", style: "background-color: #{user.hex}; color: #{text_color(from: user.hex)}") do
        user.hex
      end
    end

    def user_type(user)
      user_type_text = USER_TYPES_MAP[user.user_type]

      if user.staff_user.present?
        value_tag("[Staff] - #{user_type_text}")
      else
        value_tag(user_type_text)
      end
    end

    def user_status(user)
      if user.active? && !user.limited?
        value_tag('Active', colour: 'success')
      elsif user.limited?
        value_tag('Limited', colour: 'warning')
      else
        value_tag('Inactive', colour: 'danger')
      end
    end
  end
end
