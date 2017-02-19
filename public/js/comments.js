// Load the comments once the page is ready...
var commentTitle = $('#comments_title');
var commentSection = $('#comment_section');
var commentContainer = $('#comments');
var button = $('#comment_submit');
var commentTextArea = $('#comment_text_area');
var textArea = $('#text_area');
var remainingChars = $('#remaining');

var text = commentTextArea.val();
remainingChars.html(text.length + '/' + limit);
enableDisableButton(text);

$(document).ready(function() {

    fetchComments();

    commentTextArea.on('input', function(e) {
        text = commentTextArea.val().trim();
        remainingChars.html(text.length + '/' + limit);
        if (text.length > limit) {
            setDanger();
            //disableCTRLSend();
        } else if (text.length >= limit - 10) {
            setWarning();
            //enableCTRLSend(text);
        } else {
            setNormal();
            //enableCTRLSend(text);
            enableDisableButton(text);
        }
    });

    button.on('click', function(e) {
        disableButton();
        post(text);
    });
});

function disableCTRLSend() {
    commentTextArea.keydown(null);
}

function enableCTRLSend(text) {
    commentTextArea.keydown(function(e) {
        if (e.keyCode == 13 && e.ctrlKey) {
            disableButton();
            post(text);
        }
    });
}

function fetchComments() {
    $.ajax({
        type: 'get',
        data: 'usernames=true',
        url: '/json/episodes/get_comments?id=' + episodeId,
        success: function(message) {
            if (message.err) {
                console.log('Could not retrieve the comments: ' + message.err);
                commentTitle.html('Comments are unavailable.');
            } else {
                console.log(message);
                comments = message.comments;
                if (comments.length < 1) {
                    commentTitle.html('No comments yet.');
                } else if (comments.length == 1) {
                    commentTitle.html('One comment.');
                } else {
                    commentTitle.html('Comments (' + comments.length + ')');
                }
                message = "";
                for (var i = 0; i < comments.length; i++) {
                    comment = comments[i];
                    username = comment.user_id;

                    var isCurrent = username == currentUser;

                    if (isCurrent) {
                        username = "<u class='italic'>You</u> said";
                    }
                    time = comment.time;
                    text = comment.text;

                    username_text = '<span class="strong">' + username + '</span>';
                    time_text = '<span class "underline">' + time + '</span>';
                    comment_text = '<p>' + text + '</p>';

                    
                    message += '<hr/>';
                    message += username_text;
                    message += '<span> on </span>';
                    message += time_text;
                    if (!isCurrent) {
                        message += '<span> said...</span>';
                    } else {
                        message += '<span>:</span>'
                    }
                    message += comment_text;
                }
                commentContainer.html(message);
            }
        },
        fail: function(message) {
            commentTitle.html('Comments are unavailable.');
        }
    });
};

function post(text) {
    $.ajax({
        type: 'post',
        data: 'comments=' + text,
        url: '/json/episodes/add_comment?id=' + episodeId,
        success: function(message) {
            commentTextArea.val('');
            result = message.response;
            console.log(message);
            fetchComments();
            enableButton();
        }
    });
};

function setDanger() {
    remainingChars.removeClass('warning');
    remainingChars.addClass('danger');
    disableButton();
};

function setWarning() {
    remainingChars.removeClass('danger');
    remainingChars.addClass('warning');
    enableButton();
};

function setNormal() {
    remainingChars.removeClass('warning');
    remainingChars.removeClass('danger');
    enableButton();
};

function disableButton() {
    button.addClass('disabled');
};

function enableButton() {
    button.removeClass('disabled');
};

function enableDisableButton(text) {
    if (text.trim() == 0) {
        disableButton();
    } else {
        enableButton();
    }
};
