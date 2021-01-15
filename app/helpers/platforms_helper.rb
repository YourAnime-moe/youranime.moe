# frozen_string_literal: true

module PlatformsHelper
  def popular_platforms
    @popular_platforms ||= ShowUrl.popular_platforms
  end

  def current_platform
    return @current_platform if @current_platform.present?

    return unless params[:name].present? && popular_platforms.include?(params[:name])
    @current_platform = Platform.find_by(name: params[:name])
  end

  def can_show_full_release_schedule?
    current_user.present? || current_platform.present?
  end
end
