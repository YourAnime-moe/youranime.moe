var watched_episodes = $('html').find('.watched');
for (var i = 0; i < watched_episodes.length; i++) {
  console.log('Hwllo %s', i);
  watched_episodes[i].title = "You've already watched this episode.";
  var name = watched_episodes[i].children[0].attributes.name;

  if (name) {
    var id = name.textContent;
    
    videos = localStorage.getItem('videos');
    if (!videos) {
      break;
    }
    videos = JSON.parse(videos);
    if (!videos) {
      break;
    }
    console.log("%d video(s)", videos.length)
    for(var j = 0; j < videos.length; j++) {
        episode = videos[j];
        console.log("found episode")
        if (episode.videoId == id) {
            if (episode.ratio !== undefined) {
                var progressBar = $('div#progress_' + id);
                ratioInfo = 'width: ' + parseInt(episode.ratio) + '%;';
                progressBar.attr('style', ratioInfo);
                progressBar.removeClass('hidden');
            }
        }
    }
  }
}

console.warn("ok!!")
var episodes = document.getElementsByClassName("watched");
$(document).ready(function() {
  [].forEach.call(episodes, function(episode_div) {
    [].forEach.call(episode_div.children, function(progress) {
      if (progress.classList.contains("progress")) {
        var progress_div = progress.children[0];
        var id = progress_div.getAttribute("episode_id");
        var videos = JSON.parse(localStorage.videos)
        [].forEach.call(videos, function(video) {
          if (video.videoID != id) {
            return;
          }
          var ratio = video.ratio;
          if (ratio) {
            var info = "width: " + ratio + "%";
            progress_div.style = info;
          }
        })
      }
    });
  });
});
