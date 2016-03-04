app.filter 'priceToIsk', ->
  (input) ->
    if !input || isNaN(input)
      return input
    else
      input = parseInt(input)
      if input >= 1000000000
        input /= 1000000000
        input = input.toFixed(2).toString() + 'B'
      else if input >= 1000000
        input /= 1000000
        input = input.toFixed(2).toString() + 'M'
      else if input >= 1000
        input /= 1000
        input = input.toFixed(2).toString() + 'K'
      else
        input = input.toFixed(2).toString()
      return input