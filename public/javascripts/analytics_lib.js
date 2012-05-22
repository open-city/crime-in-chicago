/*!
 * Google Analytics Library
 * https://github.com/open-city/google-analytics-lib
 *
 * Copyright 2012, Nick Rougeux and Derek Eder of Open City
 * Licensed under the MIT license.
 * https://github.com/open-city/google-analytics-lib/wiki/License
 *
 * Date: 5/9/2012
 *
 */

var analyticsTrackingCode = 'UA-29226307-1';

var _gaq = _gaq || [];
_gaq.push(['_setAccount', analyticsTrackingCode]);
_gaq.push(['_trackPageview']);

(function() {
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

analyticsTrackEvent = function (category, action, label) {
	if (typeof(_gaq) != 'undefined')
    _gaq.push(['_setAccount', analyticsTrackingCode]);
		_gaq.push(['_trackEvent', category, action, label]);
};

jQuery(function () {

	jQuery('a').click(function () {
		var $a = jQuery(this);
		var href = $a.attr("href");

		//links going to outside sites
		if (href.match(/^http/i) && !href.match(document.domain)) {
			analyticsTrackEvent("Outgoing", "Click", href);
		}

		//direct links to files
		if (href.match(/\.(avi|css|doc|docx|exe|gif|js|jpg|mov|mp3|pdf|png|ppt|pptx|rar|txt|vsd|vxd|wma|wmv|xls|xlsx|zip)$/i)) {
			analyticsTrackEvent("Downloads", "Click", href);
		}

		//email links
		if (href.match(/^mailto:/i)) {
			analyticsTrackEvent("Emails", "Click", href);
		}
	});
});
