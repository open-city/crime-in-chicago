//= require fusion_maps
//= require jquery.min
//= require jquery-addons
//= require jquery-ui.min
//= require jquery.tooltip.min
//= require jquery.sparkline.min
//= require d3
//= require d3.time
//= require mustache
//= require jquery.ezpz_hint.min
//= require open-city-crime

$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  OpenCity.CrimeInChicago.url = "http://www.crimeinchicago.org";
});

