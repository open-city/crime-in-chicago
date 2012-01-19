$(function() {
  // Sparklines
  $(".sparkline").sparkline("html", {
    chartRangeMin: 0,
    fillColor: "#ddf2fb",
    height: "20px",
    lineColor: "#518fc9",
    lineWidth: 1,
    minSpotColor: "#0b810b",
    maxSpotColor: "#c10202",
    spotColor: false,
    spotRadius: 2,
    width: "240px"
  });
  
  // History toggle
  $("#history-toggle").toggle(
    function(){
      var origHeight = $("#history").height();
      $("#history").css("height", "auto");
      var autoHeight = $("#history").height();
      $("#history").css("height", origHeight + "px")
      $("#history").animate({ height: autoHeight + "px" }, 500, function(){
        $(this).find(".toggle-overlay").hide();
      });
      $(this).text("Less");
    },
    function(){
      $("#history .toggle-overlay").show();
      $("#history").animate({ height: "575px" }, 500);
      $(this).text("More");
    }
  );
  
  // DataTables
  $("#trends").dataTable({
    "aoColumns": [
      null,
      { "bSortable": false },
      null,
      null,
      null,
      null
    ],
    "bFilter": false,
    "bInfo": false,
    "bLengthChange": false,
    "bPaginate": false
  });
});