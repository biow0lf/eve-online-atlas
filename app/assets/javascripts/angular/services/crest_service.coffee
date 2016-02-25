app.factory 'crestService', ['$q', '$http', ($q, $http) ->

  factory = {}

  factory.isValidSystem = (system) ->
    return $http.get("/api/v1/solarsystems/#{system}")

  factory.getPrices = (system, items) ->
    names = encodeURI(items)
    return $http.get("/api/v1/items?name=#{names}&system=#{system}")

  factory.getTheraInfo = (system) ->
    return $http.get("/thera?system=#{system}")

  factory.getUser = ->
    return $http.get("/users")

  factory.signout = ->
    return $http.get("/signout")

  return factory
]
