var FusiontableWard = {};
var map = null;
var fusionTableId = 2954091;
var chicago = new google.maps.LatLng(41.8781136, -87.66677856445312);

FusiontableWard.create = function(number, selector) {
  
  var simpleWardStyles = [
    {
      featureType: "road",
      stylers: [
        { visibility: "off" },
        { saturation: -100 }
      ]
    },
    {
      featureType: "landscape",
      stylers: [
        { lightness: 75 },
        { saturation: -100 }
      ]
    },
    {
      featureType: "transit",
      stylers: [
        { visibility: "off" }
      ]
    },
    {
      featureType: "poi",
      stylers: [
        { lightness: 60 },
        { saturation: -100 }
      ]
    },
    {
      featureType: "water",
      stylers: [
        { hue: "#00b2ff" }
      ]
    }
  ];

  var myOptions = {
    zoom: 9,
    center: chicago,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    scrollwheel: false,
    draggable: false,
    streetViewControl: false,
    zoomControl: false,
    suppressInfoWindows: true,
    disableDoubleClickZoom: true
  };
  map = new google.maps.Map(document.getElementById(selector), myOptions);
  map.setOptions({styles: simpleWardStyles});
  
  var wardKML = new google.maps.FusionTablesLayer(fusionTableId, {
    query: "SELECT geometry FROM " + fusionTableId + " WHERE name = " + number,
    suppressInfoWindows: true
    }
  );
  
  wardKML.setMap(map);
  FusiontableWard.getMapBounds(number);
}

FusiontableWard.getMapBounds = function(number) {
	//set the query using the parameter
  var searchStr = "SELECT geometry FROM " + fusionTableId + " WHERE name = '" + number + "'";
  
  //set the callback function
  FusiontableWard.getFTQuery(searchStr).send(FusiontableWard.setMapBounds);

}

FusiontableWard.setMapBounds = function(response) {
  if (response.getDataTable().getNumberOfRows() > 0)
  {
    var map_bounds = new google.maps.LatLngBounds();
    var kml = response.getDataTable().getValue(0, 0);
    kml = kml.replace("<Polygon><outerBoundaryIs><LinearRing><coordinates>", "");
    kml = kml.replace("</coordinates></LinearRing></outerBoundaryIs></Polygon>", "");
    var boundPoints = kml.split(" ");
    
    for(var i=0; i<boundPoints.length; i++) { 
      var boundItem = boundPoints[i].split(",");
      var point = new google.maps.LatLng(parseFloat(boundItem[1]), parseFloat(boundItem[0]));
      
      map_bounds.extend(point);
    }
    map.fitBounds(map_bounds);
  }
}

FusiontableWard.getFTQuery = function(sql) {
		var queryText = encodeURIComponent(sql);
		return new google.visualization.Query('http://www.google.com/fusiontables/gvizdata?tq='  + queryText);
	}