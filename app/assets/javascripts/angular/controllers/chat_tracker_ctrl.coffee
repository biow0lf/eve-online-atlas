app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', ($scope, $http, $interval, crestService) -> do =>
  @bookmark = 1
  @selected = []
  @file = new File([""], "")
  @lastMod = @file.lastModifiedDate
  @lastCommandTime = new Date('1969.12.31 18:00:00')
  @allCommands = ['pcs!', 'pcb!']
  @interval = null
  @regionId = 10000002
  @commands = []
  @commandsToShow = []

  @filter = {
    options: {
      debounce: 500
    }
  }

  @query = {
    filter: '',
    order: 'nameToLower',
    limit: 5,
    page: 1
  }

  clearMarketTable = =>
    @selected = []
    @commands = []
    @commandsToShow = []

  # credit - https://gist.github.com/hurjas/2660489
  timeStamp = (t) ->
    # Create a date object with the current time
    if t != undefined
      now = new Date(t)
    else
      now = new Date
    # Create an array with the current month, day and time
    date = [
      now.getMonth() + 1
      now.getDate()
      now.getFullYear()
    ]
    # Create an array with the current hour, minute and second
    time = [
      now.getHours()
      now.getMinutes()
      now.getSeconds()
    ]
    # Determine AM or PM suffix based on the hour
    suffix = if time[0] < 12 then 'AM' else 'PM'
    # Convert hour from military time
    time[0] = if time[0] < 12 then time[0] else time[0] - 12
    # If hour is 0, set it to 12
    time[0] = time[0] or 12
    # If seconds and minutes are less than 10, add a zero
    i = 1
    while i < 3
      if time[i] < 10
        time[i] = '0' + time[i]
      i++
    # Return the formatted string
    return date.join('/') + ' ' + time.join(':') + ' ' + suffix

  getTrimmedMean = (items, trimPercentage) =>
    itemPrices = _.map(items, (item) -> return item.price).sort()
    toTrim = Math.round(itemPrices.length * trimPercentage)
    trimmedItems = itemPrices.slice(toTrim, itemPrices.length)
    trimmedItems = trimmedItems.slice(0, trimmedItems.length - toTrim)
    price = _.mean(trimmedItems)
    if price > 1000000000
      price /= 1000000000
      price = price.toFixed(2).toString() + 'B isk'
    else if price > 1000000
      price /= 1000000
      price = price.toFixed(2).toString() + 'M isk'
    else if price > 1000
      price /= 1000
      price = price.toFixed(2).toString() + 'K isk'
    else
      price = price.toFixed(2).toString() + ' isk'
    return price

  tick = =>
    if @file != null && @file.lastModifiedDate.getTime() != @lastMod.getTime()
      @lastMod = @file.lastModifiedDate
      readFile(@file)

  setFile = (file) =>
    @file = file

    if @interval != null
      $interval.cancel(@interval)
    @interval = $interval(tick, 250)
    return

  readFile = (file) =>
    if file.size != 0
      fileReader = new FileReader
      fileReader.onload = (e) =>
        text = e.target.result;
        # console.log text
        lines = text.split(/[\r\n]+/g); # tolerate both Windows and Unix linebreaks
        for line in lines
          # strip out whitespace on either side
          line = _.trim(line)
          # check to see if line contains a command
          command = _.filter(@allCommands, (command) -> return line.indexOf(command) >= 0)
          if command.length > 0
            c = command[0]
            commandTime = new Date(line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)[0])
            if commandTime.getTime() > @lastCommandTime.getTime()
              # if command is after newest command timestamp, save command time and execute command
              @lastCommandTime = commandTime
              value = line.substr(line.indexOf(c)+c.length+1, line.length)

              splits = _.split(value, ',')
              converted = _.map(splits, (s) ->
                int = _.parseInt(s)
                if _.isNaN(int)
                  return _.trim(s)
                else
                  return int
              )

              if command.indexOf('pcb!') >= 0
                crestService.getBuyPrices(@regionId, converted).then (responses) =>
                  for response in responses
                    price = getTrimmedMean(response.data.items, 0.2)
                    @commands.push({id: @commands.length, time: timeStamp(), buyOrder: true, sellOrder: false, name: 'PriceCheckBuy', result: {item: response.data.items[0].type.name, price: price}})
                  onPaginate(@query.page, @query.limit)

              else if command.indexOf('pcs!') >= 0
                crestService.getSellPrices(@regionId, converted).then (responses) =>
                  for response in responses
                    @commands.push({id: @commands.length, time: timeStamp(), buyOrder: false, sellOrder: true, name: 'PriceCheckSell', result: {item: response.data.items[0].type.name, price: getTrimmedMean(response.data.items, 0.2)}})
                  onPaginate(@query.page, @query.limit)

      fileReader.readAsText file

  onPaginate = (page, limit) =>
    # console.log 'page', page, 'limit', limit
    @query.page = page
    @query.limit = limit
    initial = (page - 1) * limit
    # case 1 - there are enough commands to paginate
    if initial < @commands.length
      if @commands.length - initial >= limit
        # and there are enough commands left to show at least the limit
        @commandsToShow = @commands.slice(initial, initial + limit)
      else
        # or there aren't enough, and just show what's left
        @commandsToShow = @commands.slice(initial, @commands.length)
    else
      # case 2 - not enough to paginate
      @commandsToShow = @commands
    # console.log @query.page, @query.limit, initial, @commandsToShow

  onReorder = (order) =>
    @query.order = order
    # need to do reorder logic


  removeFilter = =>
    # @filter.show = false
    @query.filter = ''

  init = =>
    return

  init()

  $scope.$watch (=> @query.filter), (newValue, oldValue) =>
    if !oldValue then @bookmark = @query.page
    if newValue != oldValue then @query.page = 1
    if !newValue then @query.page = @bookmark
    # need to update commandsToShow with things
    return

  #-- Public Functions

  @setFile = setFile
  @onPaginate = onPaginate
  @onReorder = onReorder
  @removeFilter = removeFilter
  @clearMarketTable = clearMarketTable
  @timeStamp = timeStamp

  return
]
