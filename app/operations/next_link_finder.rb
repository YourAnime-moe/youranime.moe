# frozen_string_literal: true

class NextLinkFinder < ApplicationOperation
  input :path, accepts: String, type: :keyword, required: true

  def execute
    exclude = %r{\w+\:\/\/.*}
    return '/' if exclude =~ path

    Rails.application.routes.recognize_path(path)
    path
  rescue ActionController::RoutingError
    '/'
  end
end
