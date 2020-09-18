class QueuesController < AuthenticatedController
  def main
    @queue = current_user.main_queue
    @unavailable_shows = current_user.main_queue.unavailable_shows.optimized
    set_title(before: t('anime.shows.main-queue'))
  end
end
