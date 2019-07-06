# frozen_string_literal: true

module ApplicationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :app_title, :set_title, :current_state, :maintenance_activated?
  end

  def app_title
    @app_title
  end

  def set_title(before: nil, after: nil, reset: true)
    @app_title = nil if reset
    initialize_app_title unless app_title?
    build_app_title(before: before, after: after)
  end

  def maintenance_activated?(user: nil)
    user = current_user || user
    if !user.nil? && ENV['TANOSHIMU_MAINTENANCE'] == 'true'
      !user.admin?
    else
      false
    end
  end

  def current_state
    controller_name = params[:controller].downcase
    action_name = params[:action].downcase
    "#{controller_name}::#{action_name}"
  end

  private

  def initialize_app_title
    @app_title = t('app.name')
  end

  def build_app_title(before:, after:)
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title += " | #{after}" unless after.nil?
    @app_title
  end

  def app_title?
    !@app_title.nil?
  end
end
