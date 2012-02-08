// Numbers with commas
jQuery.fn.dataTableExt.oSort['number-comma-asc'] = function(a,b) {
	/* Remove any commas (assumes that if present all strings will have a fixed number of d.p) */
	var x = a == "-" ? 0 : a.replace( /,/g, "" );
	var y = b == "-" ? 0 : b.replace( /,/g, "" );
	
	/* Parse and return */
	x = parseFloat( x );
	y = parseFloat( y );
	return x - y;
};

jQuery.fn.dataTableExt.oSort['number-comma-desc'] = function(a,b) {
	/* Remove any commas (assumes that if present all strings will have a fixed number of d.p) */
	var x = a == "-" ? 0 : a.replace( /,/g, "" );
	var y = b == "-" ? 0 : b.replace( /,/g, "" );
	
	/* Parse and return */
	x = parseFloat( x );
	y = parseFloat( y );
	return y - x;
};
