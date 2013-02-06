# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
    Morris.Line
        element: 'months_chart'
        data: $('#months_chart').data('months')
        xkey: 'mend'
        ykeys: ['gross','net']
        labels: ['Gross','Net']