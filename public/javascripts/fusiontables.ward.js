var FusiontableWard = {};
var FusiontableAllWards = {};
var map = null;
var fusionTableId = 2954091;
var chicago = new google.maps.LatLng(41.8781136, -87.66677856445312);

FusiontableAllWards.create = function(selector) {
  var myOptions = {
      zoom: 10,
      center: chicago,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false,
      streetViewControl: false,
      suppressInfoWindows: true
  };
  
  map = new google.maps.Map(document.getElementById(selector), myOptions);
  map.setOptions({styles: FusiontableWard.getMapStyle()});
  
  var wardKML = new google.maps.FusionTablesLayer(fusionTableId, {
    query: "SELECT geometry FROM " + fusionTableId,
    suppressInfoWindows: true,
    styles: {
      where: "name = '1'",
      polygonOptions: {
        fillColor: "#000000",
        fillOpacity: 1
      }
    }
  });
  
  wardKML.setMap(map);
  
  //click listener
	google.maps.event.addListener(wardKML, 'click', function(q) {
    console.log(q.row['name'].value);
    Ward.create(q.row['name'].value, '2011', "#ward-charts");
	});
}

FusiontableWard.create = function(number, selector, isDetail) {
  var myOptions;
  
  if (isDetail) {
    myOptions = {
      zoom: 9,
      center: chicago,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false,
      streetViewControl: false,
      suppressInfoWindows: true
    };
  }
  else {
    myOptions = {
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
  }
  
  map = new google.maps.Map(document.getElementById(selector), myOptions);
  map.setOptions({styles: FusiontableWard.getMapStyle()});
  
  var wardKML = new google.maps.FusionTablesLayer(fusionTableId, {
    query: "SELECT geometry FROM " + fusionTableId + " WHERE name = " + number,
    suppressInfoWindows: true
    }
  );
  
  wardKML.setMap(map);
  FusiontableWard.getMapBounds(number);
}

FusiontableWard.getMapStyle = function() { 
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
  
  return simpleWardStyles;
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
    console.log(kml);
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