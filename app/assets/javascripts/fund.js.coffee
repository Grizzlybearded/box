# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
    if($('#cumulative_return_chart').length > 0)
      Morris.Line({
        element: 'cumulative_return_chart',
        data: $('#cumulative_return_chart').data('months'),
        xkey: 'date',
        ykeys: $('#cumulative_return_chart').data('keys'),
        ymax: 'auto',
        hideHover: false,
        labels: $('#cumulative_return_chart').data('names')
      })
    $('#benchmark_name').autocomplete
      source: $('#benchmark_name').data('autocomp')