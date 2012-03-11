$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  // Ezhint overlays
  if ($.fn.ezpz_hint) {
    $(".hint").ezpz_hint();
  }

  ward_fusion_table_id = 2954091;
  chicago_centroid = new google.maps.LatLng(41.8781136, -87.66677856445312);
  ward_map_default_options = {
    zoom: 9,
    center: chicago_centroid,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    streetViewControl: false,
    suppressInfoWindows: true
  }

  if (typeof Ward !== "undefined") {
    Ward.tooltips('.chart-column .idx');
    Ward.draggable(".timeline");
    Ward.sortable("#ward-charts");
  }
});

