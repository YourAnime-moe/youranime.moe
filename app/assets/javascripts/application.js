// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require jquery_ujs
//= require jquery-ui/widgets/autocomplete
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

function retreiveMessages(container) {
    if (!container) {
        console.error("No container was specified.");
        return;
    }
    var id = container;
    var container = document.getElementById(container);
    if (!container) {
        console.error("Invalid container: %s", id);
        return;
    }
    function errorFunction(e) {
        container.innerHTML = "Sorry, there was an error while retreiving your messages. Please try again later.";
    }
    $.ajax({
        method: 'get',
        url: '/messages/all/json',
        success: function(e) {

        },
        failure: errorFunction,
        error: errorFunction
    });
}

function humanFileSize(bytes, si) {
    si = si === undefined ? true : false;
    var thresh = si ? 1000 : 1024;
    if(Math.abs(bytes) < thresh) {
        return bytes + ' B';
    }
    var units = si
        ? ['kB','MB','GB','TB','PB','EB','ZB','YB']
        : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
    var u = -1;
    do {
        bytes /= thresh;
        ++u;
    } while(Math.abs(bytes) >= thresh && u < units.length - 1);
    return bytes.toFixed(1)+' '+units[u];
}

var ajaxQueue = $({});
var currentRequest = null;
$.ajaxQueue = function( ajaxOpts ) {
    // Hold the original complete function.
    var oldComplete = ajaxOpts.complete;
    // Queue our ajax request.
    ajaxQueue.queue(function( next ) {
        // Create a complete callback to fire the next event in the queue.
        ajaxOpts.complete = function() {
            // Fire the original complete if it was there.
            if ( oldComplete ) {
                oldComplete.apply( this, arguments );
            }
            // Run the next query in the queue.
            next();
        };
        // Run the query.
        currentRequest = $.ajax( ajaxOpts );
    });
};

// Abort method
function abortAjaxQueue() {
    ajaxQueue.clearQueue();
    if (currentRequest) {
        currentRequest.abort();
    }
}

window.fadeIn = function(obj) {
  $(obj).show();
  $(obj).parents('[role="have-fun"]').fadeIn(1000);
};

$(document).ready(function() {
      //$(".button-collapse").sidenav();
      //$('.modal').modal();
      //$(".dropdown-trigger").dropdown();
      //$('select').formSelect();
      //$('.datepicker').datepicker();

      $('.dropdown-toggle').dropdown();

      var current_lang = navigator.language || navigator.userLanguage || 'en';
      if (current_lang == 'ja') {
        current_lang = 'jp';
      }
      switchTo(current_lang, false);

      [].forEach.call(document.querySelectorAll('[locale-switcher]'), function(elem) {
        elem.onclick = function(e) {
          switchTo(elem.getAttribute('locale-switcher'), true);
        }
      });

      /* $('[role="have-fun"]').on('click', function(e) {
        console.log('click!');
        if ($(this).attr('show')) {
          window.location.href = "/shows?id=" + $(this).attr('show');
        }
        if ($(this).attr('episode')) {
          window.location.href = "/shows/episodes?id=" + $(this).attr('episode');
        }
      }); */
  });

  function switchTo(locale, force) {
    $.ajax({
      url: '/set/current/locale.json',
      method: 'put',
      data: {locale: locale, set_at_first: force},
      success: function(res) {
        console.log(res);
        if (res.reload) {
          location.href = location.href;
        }
      }
    })
  }
