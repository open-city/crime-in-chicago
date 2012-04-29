var OpenCity = OpenCity || {};
OpenCity.CrimeInChicago = OpenCity.CrimeInChicago || {};
OpenCity.CrimeInChicago.url = "http://localhost:8080";
OpenCity.CrimeInChicago.fusion_table_id = 2954091;
OpenCity.CrimeInChicago.chicago_centroid = function() {
  return new google.maps.LatLng(41.8781136, -87.66677856445312);
};
OpenCity.CrimeInChicago.map_default_options = function() {
  return {
    center: OpenCity.CrimeInChicago.chicago_centroid(),
    disableDefaultUI: true,
    disableDoubleClickZoom: true,
    draggable: false,
    mapTypeControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    scrollwheel: false,
    streetViewControl: false,
    suppressInfoWindows: true,
    zoom: 9,
    zoomControl: false
  };
};

OpenCity.Ward = function(number, year, options) {
  this.number   = number;
  this.year     = year;
  this.server   = OpenCity.CrimeInChicago.url;
  this.options  = options || {};
  this.template = new OpenCity.Ward.Template(this);
  this.calendar = new OpenCity.Ward.Calendar(this, {height: 104, width: 770});

  return this;
};
OpenCity.Ward.prototype.getOption = function(option, default_options) {
  if (typeof this.options != "undefined" &&
      typeof this.options == "object" && this.options[option]) {
    return this.options[option];
  } else {
    return default_options;
  }
};
OpenCity.Ward.prototype.prefixSelector = function() {
  return OpenCity.Ward.prototype.getOption("prefixSelector", "ward"+"-"+this.number+"-"+this.year);
};
OpenCity.Ward.prototype.missing = function() {
  return $("#"+this.prefixSelector()).length == 0;
};
OpenCity.Ward.prototype.present = function(selector) {
  if (this.missing()) {
    this.template.attach($("#ward-charts"));
  }
};
OpenCity.Ward.tooltips = function(element) {
  element.tooltip({
    delay: 0,
    fade: 0,
    showBody: " - ",
    showURL: false,
    track: true
  });
};

OpenCity.Ward.Widget = function(name, url, callback) {
  this.name = name;
  this.url  = url;

  d3.json(url, function(json) {
    callback(name, $(Mustache.render(json["template"], json)));
  });

  return this;
};
OpenCity.Ward.Widget.Map = function(ward, callback) {
  var url = ward.server+"/api/wards/"+ward.number+"/"+ward.year+"/statistics/map.json";
  return new OpenCity.Ward.Widget("crime", url, callback);
};
OpenCity.Ward.Widget.Category = function(ward, callback) {
  var url = ward.server+"/api/wards/"+ward.number+"/"+ward.year+"/statistics/category.json";
  return new OpenCity.Ward.Widget("category", url, callback);
};
OpenCity.Ward.Widget.Crime = function(ward, callback) {
  var url = ward.server+"/api/wards/"+ward.number+"/"+ward.year+"/statistics/crime.json";
  return new OpenCity.Ward.Widget("crime", url, function(name, element) {
    OpenCity.Ward.tooltips(element.find(".idx"));
    callback(name, element);
  });
};
OpenCity.Ward.Widget.Sparkline = function(ward, callback) {
  var url = ward.server+"/api/wards/"+ward.number+"/"+ward.year+"/statistics/sparkline.json";
  return new OpenCity.Ward.Widget("sparkline", url, callback);
}

OpenCity.Ward.Template = function(ward) {
  this.ward = ward;
  this.base = $("<div id=\""+this.ward.prefixSelector()+"\" class=\"timeline\" data-ward=\""+this.ward.number+"\" data-year=\""+this.ward.year+"\"></div>");
  this.fusion_map = null;

  // Any template must implement the four following methods
  // close_handle()
  // title()
  // heatmap()
  // statistics()
  // setTemplateEvents
  this.attach = function(selector) {
    selector.prepend(this.base);
    this.base.append(this.close_handle());
    this.base.append(this.title());
    this.base.append(this.heatmap());
    this.base.append(this.statistics());
    this.base.append($("<div style=\"clear:both;\"></div>")); // WRITE THE CSS SO THIS IS NOT REQUIRED
    this.setTemplateEvents();
  };

  this.setTemplateEvents = function() {
    var ward = this.ward;
    var base = this.base;
    var fusion_map = this.fusion_map;

    // REMOVE WARD TEMPLATE FROM DOM
    this.base.find(".remove").click(function() {
      $("a[data-ward|='"+ward.number+"']").parent().attr("class", "");
      $(this).parent().remove();
      return false;
    });

    // EXPAND STATISTICS ELEMENT
    this.base.find(".ward-title").click(function() {
      base.find(".statistics").slideToggle(500, function() {
        if (fusion_map == null) {
          // STATISTIC MAP
          var fusion_table_id = OpenCity.CrimeInChicago.fusion_table_id;
          var map_element = base.find(".ward-map")[0];

          fusion_map = FusionMap.create(map_element, OpenCity.CrimeInChicago.map_default_options());
          var fusion_layer = FusionLayer.create({select: 'geometry', from: fusion_table_id, where: "name = '"+ward.number+"'"}, fusion_map.page_element);
          fusion_map.add_map_bounds({from: fusion_table_id, where: "name = '"+ward.number+"'"}, function(response) {
            fusion_map.set_map_bounds(response);
          });

          // RENDER SPARKLINE
          $.sparkline_display_visible();
        }
      });
      return false;
    });

  };

  this.close_handle = function() {
    return $("<a class=\"remove\" href=\"#\" title=\"Remove\">Remove</a>");
  };

  this.title = function() {
    var header = $("<h2></h2>");
    var header_name = $("<a class=\"ward-title\" href=\"#\">Ward "+this.ward.number+" ["+this.ward.year+"]</a>");
    header.append(header_name);
    var ward_detail = $("<span><a class=\"ward-details\" href=\"" + OpenCity.CrimeInChicago.url + "/wards/"+this.ward.number+"\">View all ward details</a></span>");
    header.append(ward_detail);
    return header;
  };

  this.heatmap = function() {
    var list = $("<div class=\"heatmap\"></div>");
    list.append(this.heatmap_months());
    list.append(this.heatmap_weekdays());
    var chart = this.heatmap_chart();
    list.append(chart);

    this.ward.calendar.attach(chart[0], "Blues");

    return list;
  };

  this.heatmap_months = function() {
    var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    var list = $("<ol class=\"months\"></ol>");
    $.each(months, function(index, value) {
      //var list_item = $("<li><a data-month=\""+(index + 1)+"\" href=\"#\">"+value+"</a></li>");
      var list_item = $("<li>"+value+"</li>");
      list_item.find("a").click(function() {

        new OpenCity.Ward.Widget.Category(ward, function(name, element) {
          var category = $("#ward-"+ward.number+"-"+ward.year+" .statistics .category");
          category.replaceWith(element);
        });

        return false;
      });
      list.append(list_item);
    });
    return list;
  };

  this.heatmap_weekdays = function() {
    var weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    var list = $("<ol class=\"weekdays\"></ol>");
    $.each(weekdays, function(index, value) {
     //list.append($("<li><a data-weekday=\""+index+"\" href=\"#\">"+value+"</a></li>"));
     list.append($("<li>"+value+"</li>"));
    });
    return list;
  };

  this.heatmap_chart = function() {
    return $("<div class=\"chart\" id=\"calendar-"+this.ward.number+"-"+this.ward.year+"\"></div>");
  };

  this.statistics = function() {
    var list = $("<div class=\"statistics\" style=\"display:none;\"></div>");
    var elements = [];

    function ordered_append(name, order, element) {
      element.attr("data-order", order);
      elements.push(element);

      if (elements.length > 4) {
        elements.sort(function(a, b) {
          return parseInt($(a).attr("data-order")) > parseInt($(b).attr("data-order"));
        });
        $.each(elements, function(index, value) {
          list.append(value);
        });
        elements = [];
      }
    };

    var server = OpenCity.CrimeInChicago.url;

    new OpenCity.Ward.Widget.Map(ward, function(name, element) {
      ordered_append(name, 1, element);
    });
    new OpenCity.Ward.Widget.Crime(ward, function(name, element) {
      ordered_append(name, 2, element);
    });
    new OpenCity.Ward.Widget.Category(ward, function(name, element) {
      ordered_append(name, 3, element);
    });
    new OpenCity.Ward.Widget.Sparkline(ward, function(name, element) {
      ordered_append(name, 4, element);
      element.find(".sparkline-day").sparkline("html", {
        chartRangeMin: 0, fillColor: "#ddf2fb",
        height: "31px", lineColor: "#518fc9",
        lineWidth: 1, minSpotColor: "#0b810b",
        maxSpotColor: "#c10202", spotColor: false,
        spotRadius: 2, width: "138px"
      });
    });
    ordered_append("view_details", 5, this.statistics_view_details());

    return list;
  };

  this.statistics_view_details = function() {
    var panel = create_panel("view_details", "<a rel=\"external\" href=\"/wards/"+this.ward.number+"\">View more details >></a>", {width: "16%"});
    panel.append($("<p class=\"mute\">See crime trends, full history, contact the alderman and more ...</p>"));
    return panel;
  };

  function create_panel(name, header, options) {
    var wrapper = $("<div class=\"panel\" "+(typeof options != "undefined" ? "style=\"width: "+options["width"]+";\"" : "")+"></div>");
    wrapper.addClass(name);
    wrapper.append("<h3>"+header+"</h3>");
    return wrapper;
  };

  return this;
};
OpenCity.Ward.Calendar = function(ward, options) {
  this.ward     = ward;
  this.options  = options || {};
  this.data     = new Object();
  this.day      = d3.time.format("%w"),
  this.week     = d3.time.format("%U"),
  this.percent  = d3.format(".1%"),
  this.format   = d3.time.format("%Y-%m-%d");

//  this.margins    = [0, 0, 0, 0];
//  this.width      = 590 - m[1] - m[3];
//  this.height     = 95  - m[0] - m[2];
//  this.cell       = 10.64;

  return this;
};
OpenCity.Ward.Calendar.prototype.getOption = function(option, default_options) {
  if (typeof this.options != "undefined" &&
      typeof this.options == "object" && this.options[option]) {
    return this.options[option];
  } else {
    return default_options;
  }
};
OpenCity.Ward.Calendar.prototype.margins = OpenCity.Ward.Calendar.prototype.getOption("margins", [0, 0, 0, 0]);
OpenCity.Ward.Calendar.prototype.width = function(options) {
  return this.getOption("width", 590) - this.margins[1] - this.margins[3];
};
OpenCity.Ward.Calendar.prototype.height = function(options) {
  return this.getOption("height", 95) - this.margins[0] - this.margins[2];
};
OpenCity.Ward.Calendar.prototype.cellsize = function(options) {
  return this.getOption("cellsize", 10.64);
};
OpenCity.Ward.Calendar.prototype.color = function() {
  return d3.scale.quantize().domain([0, this.crimes_max]).range(d3.range(0));
};
OpenCity.Ward.Calendar.prototype.svg = function(selector, class_string) {
  return d3.select(selector).selectAll("svg")
      .data(d3.range(parseInt(this.ward.year), parseInt(this.ward.year) + 1))
    .enter().append("svg")
      .attr("width", this.width)
      .attr("height", this.height)
      .attr("class", class_string)
    .append("g")
      .attr("transform", "translate(0, 1)");
};
OpenCity.Ward.Calendar.prototype.rect = function(selector, class_string) {
  return svg.selectAll(selector)
      .data(function(d) { return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
    .enter().append("rect")
      .attr("class", class_string)
      .attr("width", this.cellsize)
      .attr("height", this.cellsize)
      .attr("x", function(d) { return week(d) * this.cellsize; })
      .attr("y", function(d) { return day(d) * this.cellsize; })
      .map(this.format);
};
OpenCity.Ward.Calendar.prototype.attach = function(selector, color_class) {
  var the_ward      = this.ward;
  var the_width     = this.width();
  var the_height    = this.height();
  var the_data      = this.data;

  var week          = d3.time.format("%U");
  var day           = d3.time.format("%w");
  var format        = d3.time.format("%Y-%m-%d");
  var z             = 14.5;

  d3.json("/api/"+the_ward.year+"/wards/"+the_ward.number+"/crime/calendar", function(json) {
    the_data["crime_counts"] = [];
    the_data["crimes_sum"] = 0;
    the_data["crimes_max"] = json[0]["crime_max"]
    json.forEach(function(obj, index) {
      the_data[json[index]["date"]] = json[index]["crime_count"];
      the_data["crime_counts"][the_data["crime_counts"].length] = json[index]["crime_count"];
      the_data["crimes_sum"] = the_data["crimes_sum"] + json[index]["crime_count"];
    });

    var crimes_max = the_data["crimes_max"];
    var color         = d3.scale.quantize().domain([0, crimes_max]).range(d3.range(9));

//    this.ward.find(".summary_count").html("<strong>"+the_data["crimes_sum"]+"</strong>");

    var svg = d3.select(selector).selectAll("svg")
        .data(d3.range(parseInt(the_ward.year), parseInt(the_ward.year) + 1))
      .enter().append("svg")
        .attr("width", the_width)
        .attr("height", the_height)
        .attr("class", color_class)
      .append("g")
        .attr("transform", "translate(0, 1)");

    var rect = svg.selectAll("rect.day")
        .data(function(d) { return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
      .enter().append("rect")
        .attr("class", "day")
        .attr("width", z)
        .attr("height", z)
        .attr("x", function(d) {
          return OpenCity.Ward.Calendar.functions.week(d) * z;
        })
        .attr("y", function(d) {
          return OpenCity.Ward.Calendar.functions.day(d) * z;
        })
        .map(OpenCity.Ward.Calendar.functions.format);

    rect.append("title")
        .text(function(d) { return d; });

    svg.selectAll("path.month")
        .data(function(d) { return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
      .enter().append("path")
        .attr("class", "month")
        .attr("d", OpenCity.Ward.Calendar.functions.monthPath);

    rect.filter(function(d) { return d in the_data; })
        .attr("class", function(d) { return "day q" + color(the_data[d]) + "-9"; })
      .select("title")
        .text(function(d) { return "[" + d + "]" + ": " + the_data[d] + " crimes listed"; });

    // CALENDAR DAY TOOLTIP (SVG ELEMENT NOT SUPPORTED YET)
//    $(svg[0]).find("rect").each(function(index, element) {
//      OpenCity.Ward.tooltips(element);
//    });
  });
};

OpenCity.Ward.Calendar.functions = {};
OpenCity.Ward.Calendar.functions.day       = d3.time.format("%w");
OpenCity.Ward.Calendar.functions.week      = d3.time.format("%U");
OpenCity.Ward.Calendar.functions.percent   = d3.format(".1%");
OpenCity.Ward.Calendar.functions.format    = d3.time.format("%Y-%m-%d");
OpenCity.Ward.Calendar.functions.monthPath = function(t0) {
  var t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0);
  var d0 = + OpenCity.Ward.Calendar.functions.day(t0);
  var d1 = + OpenCity.Ward.Calendar.functions.day(t1);
  var w0 = + OpenCity.Ward.Calendar.functions.week(t0);
  var w1 = + OpenCity.Ward.Calendar.functions.week(t1);
  var z  = 14.5;

  return "M" + (w0 + 1) * z + "," + d0 * z
      + "H" + w0 * z + "V" + 7 * z
      + "H" + w1 * z + "V" + (d1 + 1) * z
      + "H" + (w1 + 1) * z + "V" + 0
      + "H" + (w0 + 1) * z + "Z";
};
OpenCity.Ward.Calendar.functions.delimiter = function(number_string, value) {
  var value = typeof value == "undefined" ? "," : value;

  var array = number_string.toString().split('').reverse();
  for(x = 3; x < array.length; x = x + 3) {
    array.splice(x, 0, value);
    x++;
  }
  return array.reverse().join('');
};


// To be removed
OpenCity.Ward.Calendar.prototype.missing = function() {
  var ward_element = $("#ward-"+this.ward.number+"-"+this.ward.year);
  return ward_element.length == 0;
}

