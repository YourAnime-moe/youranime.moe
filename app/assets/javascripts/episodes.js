$(document).on('turbolinks:load', function() {
  // Global variables
  var goingToShow = false;
  var goingToEpisode = false;
  var inactivityTime = 5000;
  var timeoutId;

  var $video = null;
  var $playing_btn = null;
  var $paused_btn = null;

  if ($('.video-body').size() > 0) {
    $playing_btn = $('.playing');
    $paused_btn = $('.paused');

    $('[go-to-show]').on('click', goToShow);
    $('[go-to-episode]').on('click', goToEpisode);
    $('[hf-action]').on('click', execHfAction);

    $video = $('#video-obj');
    $video.on('play', onPlay);
    $video.on('timeupdate', onProgress);
    $video.on('pause', onPause);
    $video.on('ended', onEnded);
    $video.on('loadedmetadata', setVideoDuration);

    document.addEventListener("mousemove", cancelFadeOutInControls, false);
    document.addEventListener("mousedown", cancelFadeOutInControls, false);
    document.addEventListener("keypress", cancelFadeOutInControls, false);
    document.addEventListener("touchmove", cancelFadeOutInControls, false);

    setFadeOutInControls();

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

    function execHfAction(e) {
      if (this.getAttribute('hf-action') === 'toggle-play-pause') {
        togglePlayPause();
      }
    }

    function togglePlayPause(callback) {
      if (isPlaying()) {
        pause(callback);
      } else {
        play(callback);
      }
    }

    function setVideoDuration() {
      var hours = parseInt($video.get(0).duration / 60 / 60, 10);
      var minutes = parseInt($video.get(0).duration / 60, 10);
		  var seconds = parseInt($video.get(0).duration % 60);

      min_sec = stringifyInts(minutes) + ':' + stringifyInts(seconds);
      if (hours > 0) {
        hours = stringifyInts(hours) + ':'
        $('time').children('.hours').show().text(hours);
      } else {
        $('time').children('.hours').hide();
      }
      $('time').children('.duration').text(min_sec);
    }

    function stringifyInts(value) {
      if (value < 10) {
        value = '0' + value;
      } else {
        value = '' + value
      }
      return value;
    }

    function play(callback) {
      $video.get(0).play().then(callback);
    }

    function onProgress(e) {
      var start = this.currentTime;
      var total = this.duration;
      var loadPercentage = (start/total)*100;

    }

    function onPlay(e) {
      $playing_btn.addClass('active');
      $paused_btn.removeClass('active');
    }

    function onPause(e) {
      $playing_btn.removeClass('active');
      $paused_btn.addClass('active');
    }

    function onEnded() {
      cancelFadeOutInControls(true);
    }

    function pause(callback) {
      $video.get(0).pause();
      if (typeof(callback) === 'function') {
        callback();
      }
    }

    function isPlaying() {
      return !isPaused();
    }

    function isPaused() {
      return $video.get(0).paused;
    }

    function setFadeOutInControls() {
      showControls();
      timeoutId = timeoutId = setTimeout(hideControls, inactivityTime);
    }

    function cancelFadeOutInControls(stop) {
      clearTimeout(timeoutId);
      if (stop !== undefined && stop === true) {
        showControls();
      } else {
        setFadeOutInControls();
      }
    }

    function hideControls() {
      $('.controls-container').fadeOut(function() {
        $('.video-body').addClass('muchuu');
      });
    }

    function showControls() {
      $('.video-body').removeClass('muchuu');
      $('.controls-container').fadeIn();
    }
  }
});
