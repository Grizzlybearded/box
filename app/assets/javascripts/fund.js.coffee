# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
    if($('#aum_chart').length > 0)
      Morris.Line({
        element: 'aum_chart'
        data: $('#aum_chart').data('months')
        preUnits: '$'
        xkey: 'mend'
        ykeys: ['aum']
        labels: ['AUM']
      })
    if($('#gross_net_chart').length > 0)
      Morris.Line({
        element: 'gross_net_chart'
        data: $('#gross_net_chart').data('months')
        postUnits: '%'
        xkey: 'mend'
        ykeys: ['gross', 'net']
        labels: ['Gross','Net']
      })
    if($('#cumulative_return_chart').length > 0)
      Morris.Line({
        element: 'cumulative_return_chart',
        data: $('#cumulative_return_chart').data('months'),
        xkey: 'date',
        ykeys: ['fund_one', 'fund_two', 'fund_three'],
        ymax: 'auto',
        hideHover: false,
        labels: $('#cumulative_return_chart').data('names')
      })