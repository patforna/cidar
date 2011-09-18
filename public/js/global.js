$(document).ready(function() {
  getAndShowTopGit();
  
  var FIVE_SECONDS = 5000;
  $.ajaxSetup ({ cache: false });
  
  function refresh_content() {
    $("#container").load(window.location + " #container");
  }
                                
  setInterval(refresh_content, FIVE_SECONDS)
  setInterval(getAndShowTopGit, 2 * FIVE_SECONDS)
});

function getAndShowTopGit() {
  var response = $.ajax({ type: "GET", url: '/git/top-git-today.json', async: false });
  if (response.status != 200) {
    console.log("Unable to retrieve json data");
    console.log(response);
    return;
  }
  
  var jsonData = response.responseText;
  var data = JSON.parse(jsonData);
  
  currentTotal = data.total;
  $('#top-git .total').text(currentTotal);

  $('#top-git .commiters .commiter').remove();
  
  $.each(data.top, function(index, pair) {
    var commiter = $('<span/>');
    commiter.attr('class', 'commiter');
    commiter.text(pair[1] + " " + pair[0]);
    $('#top-git .commiters').append(commiter);
  });
  
}
