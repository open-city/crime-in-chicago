$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  Ward.tooltips('.chart-column .idx');
  Ward.draggable(".timeline");
  Ward.sortable("#ward-charts");
});
