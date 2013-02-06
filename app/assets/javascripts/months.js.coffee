# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $(".table-sortable").dataTable
    aaSorting: []     # disable default sort (remove this line to enable it)
    bPaginate: false  # Remove pagination
    bFilter: false    # Remove filter
    bInfo: false      # Remove useless info
    # Columns with .unsortable class are not sortable
    aoColumnDefs : [
      'bSortable': false,
      'aTargets': ['unsortable']
    ]