$(document).ready(function($) {
  var refreshProgress = function () {
    job_id = $('#job-id').text();
    $.get('/import/status', {job_id: job_id}, function (data, status, xhr) {
      console.log('done with this shit');
      console.log(data);
      console.log(status);
      console.log(xhr);
      // $('#import-status').html(data);
      setTimeout(refreshProgress, 2000);
    }).fail(function (xhr, status, err) {
      console.log('error');
      console.log(xhr);
      console.log(status);
      console.log(err);
    });
  };
  $('#import-form').on('ajax:success', function(e, data, status, xhr) {
    $('#import-status').html(xhr.responseText);
    refreshProgress();
  });
  $('#import-form').on("ajax:error", function() {
    $('#import-status').html('ERROR');
  });
  // $('#import-status').bind('DOMSubtreeModified', refreshProgress)
});
