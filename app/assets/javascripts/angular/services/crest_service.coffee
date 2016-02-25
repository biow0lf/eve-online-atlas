app.factory 'crestService', ['$q', '$http', ($q, $http) ->

  factory = {}

  factory.isValidSystem = (system) ->
    $http.get("/api/v1/solarsystems?name=#{system}")

  factory.getPrices = (system, items) ->
    names = encodeURI(items)
    return $http.get("/api/v1/items?name=#{names}&system=#{system}")

  factory.getTheraInfo = (system) ->
    return $http.get("/thera?system=#{system}")
	
  factory.getAgents = (system) ->
    return $http.get("api/v1/agents?")
	
  factory.getSolarSystem = (locationID) ->
	  return $http.get("api/v1/solarsystems/#{locationID}")
	
  factory.getPlanet = (solarSystemID, planetID) ->
	  return $http.get("api/v1/solarsystems/#{solarSystemID}/planets/#{planetID}")
	
  factory.getMoon = (solarSystemID, planetID, moonID) ->
	  return $http.get("api/v1/solarsystems/#{solarSystemID}/planets/#{planetID}/moons/#{moonID}")

  factory.getUser = ->
    return $http.get("/users")

  factory.signout = ->
    return $http.get("/signout")

  return factory
]
