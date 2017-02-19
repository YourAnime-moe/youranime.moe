// JavaScript needed to play the next video automatically
var skipAt = 95;

myVideo = document.getElementById('episode_video');
myVideo.addEventListener('timeupdate', function() {
    var currentTime = parseInt(myVideo.currentTime);
    var duration = parseInt(myVideo.duration);
    var ratio = (currentTime / duration) * 100;
    
    if (ratio >= 100) {
        myVideo.pause();
        playNextVideoIfAny();
    }
});

function playNextVideoIfAny() {
    if (videoId) {
        goToNextId(videoId);
    }
}

function goToNextId(currentId) {
    console.log("Going to the next episode if any...");
    $.ajax({
        type: 'get',
        url: '/json/get/episode/next?id=' + currentId,
        success: function(e) {
            console.log(e);
            if (e.success) {
                nextId = e.next_id;
                if (!nextId) {
                    console.log("No id was found... perhaps this is the last episode?");
                } else {
                    goToEpisode(nextId);
                }
            } else {
                console.err("The server did not find the episode (no ID passed).");
            }
        },
        fail: function() {
            nextId = null;
        },
        error: function() {
            nextId = null;
        }
    });
}

function goToEpisode(id) {
    if (id) {
        console.log("Going episode id=%s", id);
        url = '/shows/episodes?id=' + id;
        window.location.replace(url);
    }
}

