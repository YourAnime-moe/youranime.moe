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
    for(var j = 0; j < videos.length; j++) {
        episode = videos[j];
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
