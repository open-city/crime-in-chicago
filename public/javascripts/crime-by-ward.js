$(function() {
      // Toggle ward highlighting
      $(".wards a").click(function(){
        $(this).parent().toggleClass("current");
      });
      
      // Dragging handles
      $(".timeline").hover(
        function(){ $(this).find(".handle").height($(this).outerHeight()); },
        function(){ $(this).find(".handle").height(0); }
      );
      
      $("#ward-charts").sortable({
        handle: ".handle",
        revert: true
      });
      
      // Toggle ward stats
      $(".timeline h2 a").toggle(
        function(){
          $(this).parents(".timeline").find("h2 a").toggleClass("expanded");
          $(this).parents(".timeline").find(".stats").slideToggle(function(){
            $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
          });
          $.sparkline_display_visible();
          return false;
        },
        function(){
          $(this).parents(".timeline").find("h2 a").toggleClass("expanded");
          $(this).parents(".timeline").find(".stats").slideToggle(function(){
            $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
          });
          $.sparkline_display_visible();
          return false;
        }
      );
      
      $(".heatmap a").click(function(){
        $(this).parents(".timeline").find("h2 a").addClass("expanded");
        $(this).parents(".timeline").find(".stats").slideDown(function(){
          $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
        });
        $.sparkline_display_visible();
        return false;
      });
      
      // Tooltips
      $('.chart-column .idx').tooltip({ 
        delay: 0,
        fade: 250,
        showBody: " - ",
        showURL: false,
        track: true
      });
      
      // Sparklines
      $(".sparkline-day").sparkline("html", {
        chartRangeMin: 0,
        fillColor: "#ddf2fb",
        height: "31px",
        lineColor: "#518fc9",
        lineWidth: 1,
        minSpotColor: "#0b810b",
        maxSpotColor: "#c10202",
        spotColor: false,
        spotRadius: 2,
        width: "138px"
      });
    });