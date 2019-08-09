# frozen_string_literal: true

module LocaleConcern
  extend ActiveSupport::Concern

  included do
    helper_method [:set_locale, :find_locale]
    before_action :render_if_not_set_first, only: [:set_locale]
  end

  def set_locale
    new_locale = memorize_locale.to_s
    render json: {
      success: true,
      reload: new_locale == requested_locale,
      locale: locale_state_response(requested: requested_locale)
    }
  end

  def find_locale
    try_to_set = params[:lang] || session[:locale]
    begin
      I18n.locale = try_to_set || :en
    rescue I18n::InvalidLocale
      Rails.logger.warn "Invalid locale #{try_to_set}. Defaulting to :en..."
      I18n.locale = :en
    end
  end

  private

  def render_if_not_set_first
    return if set_locale?

    render json: {
      success: true,
      reload: false,
      locale: locale_state_response
    }
  end

  def locale_state_response(requested: nil)
    {requested: requested, old: current_locale, current: I18n.locale}
  end

  def requested_locale
    @requested_locale ||= params[:locale]
  end

  def set_at_first?
    params[:set_at_first] == 'true'
  end

  def set_locale?
    session[:locale].nil? || set_at_first?
  end

  def filter_locale
    Config.authorized_locales.each do |authorized_locale|
      next unless authorized_locale == requested_locale

      I18n.locale = authorized_locale
      return I18n.locale
    end

    # Default to English if nothing is found
    I18n.locale = :en
  end

  def memorize_locale
    session[:locale] = filter_locale
  end

  def current_locale
    @current_locale ||= I18n.locale
  end

end
