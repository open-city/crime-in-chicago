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

Ward.calendar = function(ward, year) {
  var m = [19, 20, 20, 19], // top right bottom left margin
      w = 960 - m[1] - m[3], // width
      h = 136 - m[0] - m[2], // height
      z = 17; // cell size

  var day = d3.time.format("%w"),
      week = d3.time.format("%U"),
      percent = d3.format(".1%"),
      format = d3.time.format("%Y-%m-%d");

  var color = d3.scale.quantize()
      .domain([10, 1])
      .range(d3.range(10));

  var svg = d3.select("#chart").selectAll("svg")
      .data(d3.range(2011, 2013))
    .enter().append("svg")
      .attr("width", w + m[1] + m[3])
      .attr("height", h + m[0] + m[2])
      .attr("class", "RdYlGn")
    .append("g")
      .attr("transform", "translate(" + (m[3] + (w - z * 53) / 2) + "," + (m[0] + (h - z * 7) / 2) + ")");

  svg.append("text")
      .attr("transform", "translate(-6," + z * 3.5 + ")rotate(-90)")
      .attr("text-anchor", "middle")
      .text(String);

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

  d3.json("/wards/"+ward+"/partials/"+year+"/timeline", function(json) {
    var data = new Object();
    var jobs_sum  = 0;

    json.forEach(function(obj, index) {
      data[json[index][0]] = json[index][1];
      jobs_sum += json[index][1];
    });

    d3.select("#city_count").html(jobs_sum + " opportunities");

    rect.filter(function(d) { return d in data; })
        .attr("class", function(d) { return "day q" + color(data[d]) + "-9"; })
      .select("title")
        .text(function(d) { return "[" + d + "]" + ": " + data[d] + " opportunities found"; });
  });

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
}

