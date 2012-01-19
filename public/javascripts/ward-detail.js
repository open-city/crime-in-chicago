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
      $("#past").slideToggle();
      $(this).text("Show fewer years");
    },
    function(){
      $("#past").slideToggle();
      $(this).text("Show all years");
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