# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('#locations').live('change', ->
  loc = $('#locations').val()
  $.getJSON('/locations/' + loc + '/codes.json', (data) ->
    opts = ''
    $.each(data, (i, code) -> opts += "<option value='" + code['id'] + "'>" + code['code'] + " - " + code['name'] + "</option>")
    $('#work_entry_code_id').html(opts)))
