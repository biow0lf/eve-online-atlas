app.factory 'crestService', ['$q', '$http', ($q, $http) ->

  factory = {}

  # https://public-crest.eveonline.com/market/10000002/orders/sell/?type=https://public-crest.eveonline.com/types/34/

  factory.rootUrl = 'https://public-crest.eveonline.com'

  factory.getBuyPrices = (regionId, items) ->
    # console.log 'getBuyPrices', regionId, items
    promises = _.map(items, (item) ->
      url = "#{factory.rootUrl}/market/#{regionId}/orders/buy/?type=#{factory.rootUrl}/types/#{item}/"
      return $http(method: 'GET', url: url)
    )
    return $q.all(promises)

  factory.getSellPrices = (regionId, items) ->
    promises = _.map(items, (item) ->
      url = "#{factory.rootUrl}/market/#{regionId}/orders/sell/?type=#{factory.rootUrl}/types/#{item}/"
      return $http(method: 'GET', url: url)
    )
    return $q.all(promises)

  return factory
]
