/*
 * CONTROLLER - Javascript controller for the site.
 */
 
;var WardMap = function( $ ) { 
           
    /* Private members */
    var $body = $("body")
      , $map = $("#wardmap")
      , _width = $map.width()
      , _height = $map.height()
      , _strokeWidth = 1.0
      , _paper = Raphael( $map.get(0), _width, _height)
      , _set = _paper.set()
      , _label = _paper.popup(50, 50, "").hide()
      , _palette = {
            fill: "#A5D9EE"
          , hover: "#f5f5f5"
          , stroke: "#333333"
          , current: "#ee0000"
      };
         
    /* Init */
    function _init() {             
        // Create the map
        _createMap();
        
        // Zoom
        _zoomMap();      
    }
    $(document).ready(_init);
    
    function _createMap() {
        var maxCrimes = 10
          , colors = _palette;
                   
        // Create all of the paths
        $.each( WardMap.svg, function(k, ward) {
            var pathData = ward.svg
              , path = _paper.path(pathData)
              , pathNode = path.node
              , pathClass = "ward-" + ward.ward_number;
            
            // Set the fill color
            if( $("input[name=ward]").val() == ward.ward_number || $("select[name=ward]").val() == ward.ward_number ) {
                path.attr('fill', colors.stroke );
                $(path.node).data("selected", 1);
            } else {
                var opacity = 1;//ward.numUsers / maxCrimes;
                
                path.attr('fill', colors.fill );
                path.attr('fill-opacity', opacity);
                
                $(path.node).data({ originalColor: colors.fill, originalOpacity: opacity });
            }
            
            // Add a class
            pathNode.setAttribute("class", "ward " + pathClass);
            
            path.mouseover(function() {
                    // Ignore selected
                    if( $(this.node).data("selected") ) return;
                
                    var bbox = this.getBBox()
                      , title = "Ward " + ward.ward_number;
                
                    // Hover color
                    this.attr("fill", colors.hover);
                    this.attr("fill-opacity", 1.0);
                
                    // Show the label
                    _label.attr({ text: title}).update(bbox.x, bbox.y + bbox.height/2, bbox.width).show();
                  
                })
                .mouseout(function() {
                    // Ignore selected
                    if( $(this.node).data("selected") ) return;
                    
                    var originalColor = $(this.node).data("originalColor")
                      , originalOpacity = $(this.node).data("originalOpacity");
                    
                    // Reset the color
                    path.attr("fill", originalColor);
                    path.attr("fill-opacity", originalOpacity);
                })
                .click( function() {
                    var $self = $(this.node)
                      , wardNumber = ward.ward_number;
                      
                      $self.data("selected", 1);
                      this.attr("fill", colors.current);
                      this.attr("fill-opacity", 1.0);
                      Ward.create(wardNumber, 2011, "#ward-charts");
                });
            
            // Add this to our set
            _set.push(path);
        });
        
        // Set the fill color and stroke width
        _set.attr({'stroke-width': _strokeWidth, 'stroke': colors.stroke }).toBack();
        
        // So there aren't any lingering labels
        $map.bind("mouseout", function() {
            _label.hide();
        });
    }
    
    function _zoomMap() {
        var bBox = _set.getBBox(),
            scaleWidth =  _width / bBox.width,
            scaleHeight = _height / bBox.height,
            scale = (scaleWidth < scaleHeight) ? scaleWidth : scaleHeight,
            adjustedScale = scale * 0.95;            
            
            // TODO: This is a hack. Implement better scaling.
            _set.scale(adjustedScale, adjustedScale, 270, 550);
    }
    
    /* Public methods */
    return {}
 
}( window.jQuery );