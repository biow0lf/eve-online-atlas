app.factory 'utilsService', [ ->

  factory = {}

  factory.paginate = (data, page, limit) ->
    # console.log 'commands: page', page, 'limit', limit
    result = []
    initial = (page - 1) * limit

    while initial > data.length
      page -= 1
      initial = (page - 1) * limit

    if data.length - initial >= limit
      # and there are enough commands left to show at least the limit
      result = data.slice(initial, initial + limit)
    else
      # or there aren't enough, and just show what's left
      result = data.slice(initial, data.length)

    return [result, page]

  factory.reorder = (data, order) ->
    reverse = false
    if order.indexOf('-') >= 0
      order = _.replace(order, '-', '')
      reverse = true
    data.sort (a, b) ->
      if a[order] < b[order] then return -1
      if a[order] > b[order] then return 1
      return 0
    data.reverse() if reverse
    return data

  return factory
]
