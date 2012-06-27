// FUSION MAP OPTIONS
var FusionMapOptions = FusionMapOptions || {};
FusionMapOptions.create = function(my_options) {
  my_options = typeof my_options !== 'undefined' ? my_options : {};
  var hash = $.extend({
    zoom: 10,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    streetViewControl: false,
    suppressInfoWindows: true
  }, my_options);
  return hash;
}

// FUSION PAGE ELEMENT
var FusionPageElement = FusionPageElement || {};
FusionPageElement.create = function(selector, options) {
  options = FusionMapOptions.create(options);

  var fusion_page_element = null;
  if (typeof selector == "string") {
    fusion_page_element = new google.maps.Map(document.getElementById(selector), options);
  } else {
    fusion_page_element = new google.maps.Map(selector, options);
  }

  fusion_page_element.setOptions({styles: FusionMap.styles()});
  return fusion_page_element;
}

// FUSION MAP
var FusionMap = FusionMap || {};
FusionMap.style = FusionMap.style || {};
FusionMap.style.create = function(type, options) {
  var style = {
    featureType: type,
    stylers: []
  }

  var stylers = [];
  $.each(options, function(key, value) {
    var hash = {}; hash[key] = value;
    stylers.push(hash);
  });
  style["stylers"] = stylers;

  return style;
}
FusionMap.styles = function(options) {
  var styles = [];

  styles.push(FusionMap.style.create("road", {visibility: "off", saturation: -100}));
  styles.push(FusionMap.style.create("landscape", {lightness: 75, saturation: -100}));
  styles.push(FusionMap.style.create("transit", {visibility: "off"}));
  styles.push(FusionMap.style.create("poi", {lightness: 60, saturation: -100}));
  styles.push(FusionMap.style.create("water", {hue: "#00b2ff"}));

  return styles;
}
FusionMap.create = function(selector, options) {
  this.page_element = FusionPageElement.create(selector, options);

  this.add_map_bounds = function(query_hash, callback) {
    var fusion_query = encodeURIComponent("SELECT geometry FROM "+query_hash["from"]+" WHERE "+query_hash["where"]);
    new google.visualization.Query("http://www.google.com/fusiontables/gvizdata?tq="+fusion_query).send(callback);
  }

  this.set_map_bounds = function(response) {
    if (response.getDataTable().getNumberOfRows() > 0) {
      var map_bounds = new google.maps.LatLngBounds();
      var kml = response.getDataTable().getValue(0, 0);
      kml = kml.replace("<Polygon><outerBoundaryIs><LinearRing><coordinates>", "");
      kml = kml.replace("</coordinates></LinearRing></outerBoundaryIs></Polygon>", "");
      var boundPoints = kml.split(" ");

      for (var i = 0; i < boundPoints.length; i++) {
        var boundItem = boundPoints[i].split(",");
        var point = new google.maps.LatLng(parseFloat(boundItem[1]), parseFloat(boundItem[0]));
        map_bounds.extend(point);
        this.page_element.fitBounds(map_bounds);
      }

      //fix for not bounding close enough
      var currentZoom = this.page_element.getZoom();
      if (currentZoom < 11)
        this.page_element.setZoom(currentZoom + 1);
    }
  }

  return this;
}

// LAYER
var FusionLayer = FusionLayer || {};
FusionLayer.create = function(query_hash, page_element) {
  var layer = new google.maps.FusionTablesLayer({
    query: query_hash,
    suppressInfoWindows: true
  });

  if (typeof page_element !== "undefined") {
    layer.setMap(page_element);
  }

  return layer;
}

