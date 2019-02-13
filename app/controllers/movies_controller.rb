class MoviesController < ApplicationController

  def view
    @shows = Show.all.select {|show| show.is_movie?}
    @shows = @shows.to_a.sort_by(&:get_title)
    @shows.select! {|s| s.is_published?}
    shows = @shows.each_slice(2).to_a
    @split_shows = []
    shows.each do |show_group|
      new_group = []
      if show_group.size == 1
        new_group.push show_group[0]
      else
        first = show_group[0]
        second = show_group[1]
        if first.get_title > second.get_title
          tmp = first
          first = second
          second = tmp
        end
        new_group.push first
        new_group.push second
      end
      @split_shows.push new_group
    end
    @split_shows
    # @split_shows = Utils.split_array(Show, sort_by: 2)
    set_title(:before => t('anime.movies.view-all'))
    render 'view_all'
  end

end
