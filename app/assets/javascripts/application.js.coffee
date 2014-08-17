# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .

$ ->
  $('.flash-close a').on 'click', (event)->
    flashContainer = $(event.target).closest('.flash')
    currentFlash = $(event.target).closest('div')
    currentFlash.remove()
    if flashContainer.length == 1
      flashContainer.remove()
    event.preventDefault()
