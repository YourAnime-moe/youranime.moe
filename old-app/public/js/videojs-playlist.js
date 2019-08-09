if (videoId) {
    // Initialize the player
    var player = videojs('episode_video');
    var startAt = 0;

    // Set the playlist by fetching the playlist info from the server
    playlistInfo = []
    getPlaylistInfo(videoId, playlistInfo);
    player.playlist(playlistInfo);

    // Start the playlist
    player.playlist.autoadvance(startAt);

    function getPlaylistInfo(videoId, videosList) {
        newvideo = Object();
        newvideo.sources = [{
            src: "http://45.55.212.231/videos/hatsukoimonsutaa/ep03.mp4",
            type: "video/mp4"
        }]
        videosList.push(newvideo);
    }
}
