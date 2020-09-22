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
//= require jquery_ujs
//= require jquery-ui/widgets/autocomplete
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

function stringifyInts(value) {
  if (value < 10) {
    value = '0' + value;
  } else {
    value = '' + value
  }
  return value;
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
  $(obj).parents().children('[role="skeleton"]').hide();
  $(obj).parents('[role="have-fun"]').fadeIn(1000);
  $('[role="progress"].progress').css("display", "flex");
};

$(document).ready(function() {
    var current_lang = navigator.language || navigator.userLanguage || 'en';
    var lang_is_loading = false;
    if (current_lang == 'ja') {
      current_lang = 'jp';
    }
    switchTo(current_lang, false);

    [].forEach.call(document.querySelectorAll('[locale-switcher]'), function(elem) {
      elem.onclick = function(e) {
        if (lang_is_loading) {
          console.log('Please wait while we are changing languages...');
          return;
        }
        if ($(this).hasClass('current')) {
          return;
        }
        lang_is_loading = true;
        this.classList.add('is-loading');
        switchTo(elem.getAttribute('locale-switcher'), true);
      }
    });
});

function switchTo(locale, force) {
  $.ajax({
    url: '/set/current/locale.json',
    method: 'put',
    data: {locale: locale, set_at_first: force},
    success: function(res) {
      var current_switcher = document.querySelector('[locale-switcher="' + res.locale.current + '"]');
      if (current_switcher) {
        current_switcher.classList.add('current');
        console.log(res);
        if (res.reload) {
          location.href = location.href;
        }
      }
    }
  })
}

function loadPartial(id, url, callback) {
  const recentShowsCont = document.getElementById(id);

  $.ajax({
    url: url,
    method: 'get',
    success: function(html) {
      $(recentShowsCont).html(html);
      if (callback) { callback(); }
    },
    error: function() {
      $(recentShowsCont).html(
        '<div class="notification is-danger">Sorry, something wrong on our side! Please try again later.</div>'
      );
      if (callback) { callback(); }
    }
  });
}

if (window.requestIdleCallback) {
  requestIdleCallback(function () {
    Fingerprint2.get(function (components) {
      handleFingerprint(components);
    })
  })
} else {
  setTimeout(function () {
    Fingerprint2.get(function (components) {
      handleFingerprint(components);
    })
  }, 500);
}

function handleFingerprint(components) {
  var values = components.map(component => component.value);
  var print = Fingerprint2.x64hash128(values.join(''), 31);
  localStorage.setItem('id', print);
  return print;
}
