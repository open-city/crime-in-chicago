$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  Ward.tooltips('.chart-column .idx');
  Ward.draggable(".timeline");
  Ward.sortable("#ward-charts");

//  $(".heatmap a").click(function(){
//    $(this).parents(".timeline").find("h2 a").addClass("expanded");
//    $(this).parents(".timeline").find(".stats").slideDown(function(){
//      $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
//    });
//    $.sparkline_display_visible();
//    return false;
//  });

});
