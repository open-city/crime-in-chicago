var Ward = {};
Ward.create = function(ward, year, selector) {
  $.get("/wards/"+ward+"/"+year+"/partials/timeline", function(data) {
    $(selector).prepend(data);
    $("#ward-"+ward+" .remove").click(function() {
      $(this).parent().remove();
      return false;
    });

    $("#ward-"+ward+" h2 a").click(function() {
      $(this).parents(".timeline").find("h2 a").toggleClass("expanded");
      $(this).parents(".timeline").find(".stats").slideToggle(function(){
        $(this).parents(".timeline").find(".handle").height($(this).parents(".timeline").outerHeight());
      });
//      $.sparkline_display_visible();
      return false;
    });

    Ward.calendar(ward, 2011, "#calendar-"+ward);
  });
}

Ward.calendar = function(ward, year, selector) {
  var m = [0, 0, 0, 0], // top right bottom left margin
      w = 769 - m[1] - m[3], // width
      h = 103 - m[0] - m[2], // height
      z = 14.5; // cell size

  var data = new Object();

  var day = d3.time.format("%w"),
      week = d3.time.format("%U"),
      percent = d3.format(".1%"),
      format = d3.time.format("%Y-%m-%d");

  function monthPath(t0) {
    var t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0),
        d0 = +day(t0), w0 = +week(t0),
        d1 = +day(t1), w1 = +week(t1);
    return "M" + (w0 + 1) * z + "," + d0 * z
        + "H" + w0 * z + "V" + 7 * z
        + "H" + w1 * z + "V" + (d1 + 1) * z
        + "H" + (w1 + 1) * z + "V" + 0
        + "H" + (w0 + 1) * z + "Z";
  }

  d3.json("/api/"+year.toString()+"/wards/"+ward+"/crime/calendar", function(json) {
    data["crime_counts"] = [];
    data["crimes_sum"] = 0;
    json.forEach(function(obj, index) {
      data[json[index]["date"]] = json[index]["crime_count"];
      data["crime_counts"][data["crime_counts"].length] = json[index]["crime_count"];
      data["crimes_sum"] = data["crimes_sum"] + json[index]["crime_count"];
    });

    var crimes_max = Math.max.apply(Math, data["crime_counts"]);

    $("#summary_count").html("<strong>"+data["crimes_sum"]+"</strong>");

    var color = d3.scale.quantize()
        .domain([crimes_max, 0])
        .range(d3.range(crimes_max));

    var svg = d3.select(selector).selectAll("svg")
        .data(d3.range(year, year + 1))
      .enter().append("svg")
        .attr("width", w + m[1] + m[3])
        .attr("height", h + m[0] + m[2])
        .attr("class", "RdYlGn")
      .append("g")
        .attr("transform", "translate(0, 1)");

    var rect = svg.selectAll("rect.day")
        .data(function(d) { return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
      .enter().append("rect")
        .attr("class", "day")
        .attr("width", z)
        .attr("height", z)
        .attr("x", function(d) { return week(d) * z; })
        .attr("y", function(d) { return day(d) * z; })
        .map(format);

    rect.append("title")
        .text(function(d) { return d; });

    svg.selectAll("path.month")
        .data(function(d) { return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
      .enter().append("path")
        .attr("class", "month")
        .attr("d", monthPath);

    rect.filter(function(d) { return d in data; })
        .attr("class", function(d) { return "day q" + color(data[d]) + "-9"; })
      .select("title")
        .text(function(d) { return "[" + d + "]" + ": " + data[d] + " crimes listed"; });
  });
}

