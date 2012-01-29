var Ward = {};
Ward.create = function(number, selector) {
  $.get("/wards/"+number+"/partials/timeline", function(data) {
    $(selector).prepend(data);
    $("#ward-"+number+" .remove").click(function() {
      $(this).parent().remove();
    });

    $("#ward-"+number+" h2 a").click(function() {
      $(this).parents(".timeline").find("h2 a").toggleClass("expanded");
      $(this).parents(".timeline").find(".stats").slideToggle(function(){
        $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
      });
      $.sparkline_display_visible();
      return false;
    });
  });
}

