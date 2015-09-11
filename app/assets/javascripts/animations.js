var AnimationHandler = (function(){
  var $uiContainer,
      $agencies,
      $routes,
      $stops,
      $departures;

  function init(){
    $uiContainer = $(".ui-container");
    $agencies = $("#agencies-container");
    $routes = $("#routes-container");
    $stops = $("#stops-container");
    $departures = $("#departures-container");

    setupContainerHandlers();
  }

  function setupContainerHandlers(){
    setupAgenciesHandler();
    setupRoutesHandler();
    setupStopsHandler();
    setupResetHandler();
  }

  function setupResetHandler(){
    $uiContainer.on("click", ".reset-button", function(){
      $agencies.slideUp();
      $routes.slideUp();
      $routes.find("span").hide();
      $stops.slideUp();
      $stops.find("span").hide();
      $departures.slideUp();

      $agencies.css("margin-left", "25%");
      $routes.css("margin-left", "0");
      $stops.css("margin-left", "0");

      $agencies.delay(750).slideDown();
    })
  }

  // When we click on routes, if agencies is showing, hide it and show
  // the stops.

  function setupAgenciesHandler(){
    $agencies.on("click", "a", function(evt){
      if (!$routes.is(":visible")){
        $agencies.animate({
          'margin-left': '0'
        }, 500, function(){
          $routes.toggle("slide")
        });
      }
    })
  }

  function setupRoutesHandler(){
    $routes.on("click", "span", routesBack);
    $routes.on("click", "a",function(evt){
      if ($agencies.is(":visible")){
        $agencies.animate({
          'margin-left': '-50%',
        }, 1000, function(){
          $agencies.fadeOut()
          $stops.toggle("slide")
        });
      }
    })
  }

  function routesBack(){
    if ($stops.is(":visible")){
      $stops.toggle("slide");
      $routes.find("span").fadeOut();
      $agencies.fadeIn();
      $agencies.animate({
        'margin-left': "0",
      }, 500)
    }
  }

  function setupStopsHandler(){
    $stops.on("click", "span", stopsBack);
    $stops.on("click", "a",function(evt){
      if ($routes.is(":visible")){
        $routes.animate({
          'margin-left': '-50%',
        }, 1000, function(){
          $routes.fadeOut()
          $departures.toggle("slide")
        });
      }
    })
  }

  function stopsBack(){
    if ($departures.is(":visible")){
      $departures.toggle("slide");
      $stops.find("span").fadeOut();
      $routes.fadeIn();
      $routes.animate({
        'margin-left': "0",
      }, 500)
    }
  }

  return {
    init: init,
  };
})();

$(document).ready(function(){
  AnimationHandler.init();
  $.ajax({
    url: "get_agencies",
    type: "GET",
    dataType: "script",
  });
});
