$('document').ready(function() {
	function getContextMenu() {
		return {
			delegate: '.hasmenu',
			menu: [
				{title: "Copy", cmd: "copy", uiIcon: "ui-icon-copy"}
			]
		}
	};

	// $('#has_menu').contextmenu(getContextMenu())
});
