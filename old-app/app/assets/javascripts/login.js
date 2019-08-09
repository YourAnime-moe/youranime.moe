
function login(error_p_id, waiting_p_id, success_p_id, form_id, callback) {

	function edForm(form, readOnly) {
		if (form && form.elements) {
			var elements = form.elements;
			[].forEach.call(elements, function(e) {
				e.readOnly = readOnly;
				if (readOnly) {
					e.classList.add('disabled');
				} else {
					e.classList.remove('disabled');
				}
			});
		}
	}

	function disableForm(form) {
		edForm(form, true);
	}

	function enableForm(form) {
		edForm(form, false);
	}

	if (!error_p_id) {
		console.error("Please specify an error ID.");
		if (typeof(callback) === 'function') {
			callback();
		}
		return false;
	}
	var error_container = document.getElementById(error_p_id);
	var waiting_container = document.getElementById(waiting_p_id);
	var success_container = document.getElementById(success_p_id);

	if (!error_container || !waiting_container || !success_container) {
		console.error(
			"Error ID %s, Waiting ID %s or Success ID %s do(es) not exist in this application.",
			error_p_id,
			waiting_p_id,
			success_p_id
		);
		if (typeof(callback) === 'function') {
			callback();
		}
		return false;
	}
	var form_container = document.getElementById(form_id);
	if (!form_container) {
		console.error(
			"Form ID missing or invalid (%s)",
			form_id
		);
		return false;
	}
	var one = document.getElementById('username').value;
	var two = document.getElementById('password').value;

	waiting_container.innerHTML = "Loading, please wait...";
	disableForm(form_container);
	error_container.innerHTML = "";

	// var next = location.search;
	// if (next) {
	// 	next = next.substring(1, next.length);
	// }

	$.ajax({
		url: '/login',
		method: 'post',
		data: {
			username: one,
			password: two
		},
		success: function(e) {
			error_container.innerHTML = "";
			if (!e.success) {
				enableForm(form_container);
				error_container.innerHTML = e.message;
				if (typeof(callback) === 'function') {
					callback();
				}
			} else {
				success_container.innerHTML = e.message;
				document.location.replace(e.new_url);
			}
		},
		failure: function(e) {
			enableForm(form_container);
			error_container.innerHTML = e.message;
			if (typeof(callback) === 'function') {
				callback();
			}
		},
		error: function(e) {
			enableForm(form_container);
			error_container.innerHTML = e.toString();
			if (typeof(callback) === 'function') {
				callback();
			}
		},
		complete: function() {
			waiting_container.innerHTML = "";
		}
	});
	return false;
}
