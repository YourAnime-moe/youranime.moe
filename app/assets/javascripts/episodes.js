$(document).on('turbolinks:load', function() {
  // Global variables
  var goingToShow = false;
  var video = null;

  if ($('.video-body').size() > 0) {
    $('[go-to-show]').on('click', goToShow);
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

    function pause(callback) {

      if (typeof(callback) === 'function') {
        callback();
      }
    }
  }
});
