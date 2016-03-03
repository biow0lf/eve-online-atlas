app.factory 'crestService', ['$q', '$http', ($q, $http) ->

  factory = {}

  factory.isValidSystem = (system) ->
    $http.get("/api/v1/solar_systems?name=#{system}")

  factory.getPrices = (system, items) ->
    names = encodeURI(items)
    return $http.get("/api/v1/items/price?name=#{names}&system=#{system}&buy&sell")

  factory.getHistories = (items) ->
    names = encodeURI(items)
    return $http.get("/api/v1/items/history?name=#{names}")

  factory.getTheraInfo = (system) ->
    return $http.get("/thera?system=#{system}")

  factory.getAgents = (system) ->
    return $http.get("api/v1/agents?#{system}")

  factory.getSolarSystem = (locationID) ->
    return $http.get("api/v1/solar_systems/#{locationID}")

  factory.getNeighboringSystems = (locationID) ->
    return $http.get("api/v1/solar_systems/#{locationID}/neighbors")

  factory.getPlanet = (solarSystemID, planetID) ->
    if planetID != undefined
      return $http.get("api/v1/solar_systems/#{solarSystemID}/planets/#{planetID}")
    else return $http.get("api/v1/solar_systems/#{solarSystemID}/planets")

  factory.getStation = (solarSystemID, stationID) ->
    if stationID != undefined
      return $http.get("api/v1/solar_systems/#{solarSystemID}/stations/#{stationID}")
    else return $http.get("api/v1/solar_systems/#{solarSystemID}/stations")

  factory.getMoon = (solarSystemID, planetID, moonID) ->
    if moonID != undefined
      return $http.get("api/v1/solar_systems/#{solarSystemID}/planets/#{planetID}/moons/#{moonID}")
    else return $http.get("api/v1/solar_systems/#{solarSystemID}/planets/#{planetID}/moons/")

  factory.getUser = ->
    return $http.get("/users")

  factory.getUserLocation = ->
    return $http.get("/users/location")

  factory.signout = ->
    return $http.get("/signout")

  return factory
]