$(document).on('turbolinks:load', function() {
  // Global variables
  var goingToShow = false;
  var goingToEpisode = false;
  
  var video = null;

  if ($('.video-body').size() > 0) {
    $('[go-to-show]').on('click', goToShow);
    $('[go-to-episode]').on('click', goToEpisode);

    video = $('#video-obj')

    function goToShow(e) {
      if (goingToShow) {
        return;
      }
      goingToShow = true;
      var showId = this.getAttribute('go-to-show');
      pause(function() {
        window.location.href = '/shows/' + showId;
      });
    }

    function goToEpisode(e) {
      if (goingToEpisode) {
        return;
      }
      goingToEpisode = true;
      var showId = this.getAttribute('show-id');
      var episodeId = this.getAttribute('go-to-episode');
      pause(function() {
        window.location.href = '/shows/' + showId + '/episodes/' + episodeId;
      });
    }

    function pause(callback) {

      if (typeof(callback) === 'function') {
        callback();
      }
    }
  }
});
