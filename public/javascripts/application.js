$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  //OpenCity.CrimeInChicago.url = "http://beta.crimeinchicago.org";
});

