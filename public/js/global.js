$(document).ready(function() {
  var FIVE_SECONDS = 5000;
  $.ajaxSetup ({ cache: false });
	
	function refresh_content() {
	  $("#container").load(window.location + " #container");
	}
	                              
  setInterval(refresh_content, FIVE_SECONDS)
});
