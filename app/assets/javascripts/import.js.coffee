$ ->
  interval = 3000
  update = (id) ->
    $.ajax "/import/#{id}",
      type: "GET"
      dataType: "json"
      error: (jqXHR, s, err) ->
        console.log("Fail: #{status}, #{err}")
        setTimeout (-> update(id)), interval
      success: (data) ->
        progress = "#{data.progress}%"
        progressBar = $("span#import-progress-bar")
        progressBar.css "width", progress
        progressBar.find("p").text(progress)
        statusIcon = $("#status-icon")
        statusIcon.css "class", "icon-#{data.status}"
        if (data.status == "working" or data.status == "queued")
          setTimeout (-> update(id)), interval

  jobId = $("#job-id")
  if jobId? && jobId.length > 0
    setTimeout (-> update(jobId.text())), 1000
