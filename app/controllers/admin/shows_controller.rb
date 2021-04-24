# frozen_string_literal: true
module Admin
  class ShowsController < ApplicationController
    def index
      if show_from_query.present?
        redirect_to(admin_show_path(show_from_query))
      else
        @shows = if params[:query].present?
          Show.search(params[:query])
        else
          Show.optimized.reverse_order # .order("titles.#{I18n.locale}")
        end
        @shows_count = @shows.count
        @shows = @shows.paginate(page: params[:page])
        set_title(before: 'Shows')
      end
    end

    def show
      slug_or_id = params[:show_id] || params[:id]
      if (@show = Show.find_by_slug(slug_or_id) || Show.find_by(id: slug_or_id))
        Shows::Kitsu::Get.perform(kitsu_id: @show.reference_id, force_update: true) if @show.kitsu?
        render('show')
      else
        redirect_to(admin_shows_path, notice: 'This show does not exist!')
      end
    end

    def sync
      Sync::ShowsFromKitsuJob.perform_later(staff: current_user)
      sleep(1)

      flash[:warning] = 'Sit tight, grab a coffee: sync is in progress.'
      redirect_to(admin_shows_path)
    end

    def sync_episodes
      show = Show.find(params[:show_id])
      Sync::EpisodesFromKitsuJob.perform_later(show, staff: current_user)

      redirect_to(admin_show_path(show))
    end

    def sync_now
      show = Show.find(params[:show_id])
      Sync::ShowFromKitsuJob.perform_now(show, staff: current_user)

      redirect_to(admin_show_path(show))
    end

    def publish
      show = Show.find(params[:show_id])
      show.publish

      redirect_to(admin_show_path(show))
    end

    def unpublish
      show = Show.find(params[:show_id])
      show.unpublish

      redirect_to(admin_show_path(show))
    end

    def process_csv
      Import::ShowsCsv.perform(
        by_author: current_user,
        file: params[:shows_data].tempfile,
      )

      redirect_to(admin_shows_path)
    end

    private

    def show_from_query
      return @show_from_query if @show_from_query
      return unless params[:query].present?

      @show_from_query = Show.find_by(id: params[:query]) || Show.find_by_slug(params[:query])
    end
  end
end
