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
//= require materialize
//= require jquery_ujs
//= require jquery-ui/widgets/autocomplete
//= require turbolinks
//= require materialize-sprockets
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
