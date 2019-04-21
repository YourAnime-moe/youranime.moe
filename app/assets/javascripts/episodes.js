$(document).on('turbolinks:load', function() {
  // Global variables
  var goingToShow = false;
  var goingToEpisode = false;
  var fullscreenOn = false;
  var videoLoaded = false;
  var inactivityTime = 5000;
  var timeoutId;

  var $videoCont = null;
  var $video = null;
  var $progress = null;
  var $progressBar = null;
  var $playing_btn = null;
  var $paused_btn = null;
  var subtitlesMenu = null;

  if ($('.video-body').size() > 0) {
    $playing_btn = $('.playing');
    $paused_btn = $('.paused');
    $progress = $('.progress-filled');
    $progressBar = $('.progress-bar');
    $video = $('#video-obj');
    $videoCont = $video.parent();

    for (var i = 0; i < $video.get(0).textTracks.length; i++) {
      var track = $video.get(0).textTracks[i];
      track.mode = 'hidden';
    }

    $('[hf-action="cc"]').on('click', toggleCCMenu);

    $('[go-to-show]').on('click', goToShow);
    $('[go-to-episode]').on('click', goToEpisode);
    $('[hf-action]').on('click', execHfAction);

    $('.video-clickable-zone').on('click', togglePlayPause);
    $('.video-clickable-zone').on('dblclick', toggleFullscreen);
    $progressBar.on('click', seek);
    $video.on('play', onPlay);
    $video.on('timeupdate', onProgress);
    $video.on('pause', onPause);
    $video.on('ended', onEnded);
    $video.on('loadedmetadata', setVideoDuration);

    document.addEventListener("mousemove", cancelFadeOutInControls, false);
    document.addEventListener("mousedown", cancelFadeOutInControls, false);
    document.addEventListener("keypress", cancelFadeOutInControls, false);
    document.addEventListener("touchmove", cancelFadeOutInControls, false);
    document.addEventListener('keypress', spaceBarTogglePlay);

    setFadeOutInControls();
    initCCMenu();
    setTracks();

    function initCCMenu() {
      if ($video.get(0).textTracks) {
        var df = document.createDocumentFragment();
        subtitlesMenu = df.appendChild(document.createElement('ul'));
        subtitlesMenu.className = 'subtitles-menu';
        subtitlesMenu.appendChild(createMenuItem('subtitles-off', '', 'Off'));
        for (var i = 0; i < $video.get(0).textTracks.length; i++) {
          var track = $video.get(0).textTracks[i];
          var id = 'subtitles-' + track.language;
          var menuItem = createMenuItem(id, track.language, track.label);
          subtitlesMenu.appendChild(menuItem);
        }
        $videoCont.append($(subtitlesMenu));
      }
    }

    function createMenuItem(id, lang, label) {
      var subtitlesMenuButtons = [];
      var listItem = document.createElement('li');

      var button = listItem.appendChild(document.createElement('button'));
      button.setAttribute('id', id);
      button.className = 'subtitles-button';
      if (lang && lang.length > 0) { button.setAttribute('lang', lang); }
      button.value = label;
      button.setAttribute('data-state', 'inactive');
      button.appendChild(document.createTextNode(label));

      button.addEventListener('click', function(e) {
        subtitlesMenuButtons.map(function(v, i, a) {
          subtitlesMenuButtons[i].setAttribute('data-state', 'inactive');
        });
        var lang = this.getAttribute('lang');
        for (var i = 0; i < $video.get(0).textTracks.length; i++) {
          var track = $video.get(0).textTracks[i];
          if (track.language == lang) {
            track.mode = 'showing';
            this.setAttribute('data-state', 'active');
          } else {
            track.mode = 'hidden';
          }
        }
        subtitlesMenu.style.display = 'none';
      });

      subtitlesMenuButtons.push(button);
      return listItem;
    }

    async function setTracks() {
      var tracks = document.querySelectorAll('[load-src]');
      for (var i = 0; i < tracks.length; i++) {
        let blob = await fetch(tracks[i].getAttribute('load-src')).then(r => r.blob());
        tracks[i].src = URL.createObjectURL(blob);
      }
    }

    function toggleCCMenu(e) {
      subtitlesMenu.style.display = (
        subtitlesMenu.style.display == 'block' ? 'none' : 'block'
      );
    }

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

    function spaceBarTogglePlay(e) {
      if (e.keyCode == 32) {
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
      var duration = $video.get(0).duration;
      var hours = parseInt(duration / 60 / 60, 10);
      var minutes = parseInt(duration / 60, 10);
		  var seconds = parseInt(duration % 60);

      min_sec = stringifyInts(minutes) + ':' + stringifyInts(seconds);
      if (hours > 0) {
        hours = stringifyInts(hours) + ':'
        $('time').children('.hours').show().text(hours);
      } else {
        $('time').children('.hours').hide();
      }
      $('time').children('.duration').text(min_sec);
      videoLoaded = true;
    }

    function play(callback) {
      $video.get(0).play().then(callback);
    }

    function onProgress(e) {
      var currentTime = this.currentTime;
      var duration = this.duration;
      var loadPercentage = (currentTime / duration) * 100;
      var width = loadPercentage + '%';
      $progress.css({width: width})

      var timeleft = duration - currentTime;
      var hours = parseInt(timeleft / 60 / 60, 10);
      var minutes = parseInt(timeleft / 60, 10);
		  var seconds = parseInt(timeleft % 60);

      min_sec = stringifyInts(minutes) + ':' + stringifyInts(seconds);
      if (hours > 0) {
        hours = stringifyInts(hours) + ':'
        $('time').children('.hours').show().text(hours);
      } else {
        $('time').children('.hours').hide();
      }
      $('time').children('.duration').text(min_sec);
    }

    function onPlay(e) {
      $playing_btn.addClass('active');
      $paused_btn.removeClass('active');
    }

    function seek(e) {
      if (!videoLoaded) {
        return;
      }
      pause(function() {
        var video = $video.get(0);
        var progress = $progressBar.get(0);
        video.currentTime = (e.offsetX / progress.offsetWidth) * video.duration;
        play();
      });

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

    function toggleFullscreen() {
      if (fullscreenOn) {
        exitFullscreen();
      } else {
        enterFullscreen($('.video-body').get(0));
      }
    }

    function enterFullscreen(video) {
      if (video.requestFullscreen) {
        video.requestFullscreen();
      } else if (video.mozRequestFullScreen) {
        video.mozRequestFullScreen();
      } else if (video.webkitRequestFullscreen) {
        video.webkitRequestFullscreen();
      } else if (video.msRequestFullscreen) {
        video.msRequestFullscreen();
      }
    }

    function exitFullscreen() {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      } else if (document.msExitFullscreen) {
        document.msExitFullscreen();
      }
    }

    function onFullscreenChange(e) {
      fullscreenOn = document.fullscreenElement === e.target;
    }
  }
});
