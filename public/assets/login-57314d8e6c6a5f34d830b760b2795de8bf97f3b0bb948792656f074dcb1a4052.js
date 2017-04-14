
function login(error_p_id) {
	if (!error_p_id) {
		console.error("Please specify an error ID.");
		return;
	}
	var error_container = document.getElementById(error_p_id);
	if (!error_container) {
		console.error("Error ID %s does not exist in this application.", error_p_id);
		return;
	}
	var one = document.getElementById('username').value;
	var two = document.getElementById('password').value;

	$.ajax({
		url: '/login',
		method: 'post',
		data: 'one=' + one + '&two=' + two,
		success: function(e) {
			console.log(e);
			if (!e.success) {
				console.log(error_container);
				error_container.innerHTML = e.message;
			} else {
				document.location.replace(e.new_url);
			}
		},
		failure: function(e) {
			error_container.innerHTML = e.message;
		},
		error: function(e) {
			error_container.innerHTML = e.toString();
		}
	});
	return false;
}

;
