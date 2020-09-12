class QueuesController < AuthenticatedController
  def main
    @shows = current_user.main_queue.shows.optimized
    @unavailable_shows = current_user.main_queue.unavailable_shows.optimized
    set_title(before: t('anime.shows.main-queue'))
  end
end
