$(function() {
  $('a').each(function() {
    if ($(this).attr("rel") == "external")
      $(this).attr('target', '_blank');
  });

  OpenCity.CrimeInChicago.url = "http://localhost:8080"; // "http://beta.crimeinchicago.org";
});

