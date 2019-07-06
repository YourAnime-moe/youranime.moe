# frozen_string_literal: true

class ShowsController < AuthenticatedController
  include ShowsHelper

  before_action :ensure_show_is_available!, only: [:show]

  def index
    set_title(before: t('anime.shows.view-all'))
    @shows = published_shows
    @shows_count = @shows.count
    @additional_main_class = 'no-margin no-padding' if @shows.blank?
    @shows_parts = @shows.each_slice(4).to_a
  end

  def show
    set_title(before: @show.title)
    @episodes_parts = @show.episodes.each_slice(3).to_a
    @additional_main_class = 'no-margin no-padding'
  end

  private

  def published_shows
    return Show.search(params[:query]) if params[:query].present?

    Show.published.includes(:episodes)
  end

  def ensure_show_is_available!
    @show = Show.find_by(id: params[:id].to_i)
    return unless unavailable?(@show)

    flash[:info] = 'This show is not available yet. Please try again later.'
    redirect_to shows_path
  end

  def unavailable?(show)
    !show.try(:published?)
  end
end
