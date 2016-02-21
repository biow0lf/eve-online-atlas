app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', '$rootScope', ($scope, $http, $interval, crestService, $rootScope) -> do =>
  @bookmark = 1
  @selectedTab = 0
  @characters = []

  @file = new File([""], "")
  @interval = null
  @lastMod = @file.lastModifiedDate
  @regionId = 10000002

  @selected =
    market: []
    thera: []

  @commandTime =
    market: new Date('1969.12.31 18:00:00')
    thera: new Date('1969.12.31 18:00:00')

  @commandList =
    market: ['!pcs', '!pcb']
    thera: ['!thera']

  @commands =
    market: []
    thera: []

  @commandsToShow =
    market: []
    thera: []

  @filter = {
    options: {
      debounce: 500
    }
  }

  @query =
    market:
      filter: '',
      order: 'nameToLower',
      limit: 5,
      page: 1
      tab: 0
    thera:
      filter: '',
      order: 'nameToLower',
      limit: 5,
      page: 1
      tab: 1

  clearTable = (tab) =>
    @selected[tab] = []
    @commands[tab] = []
    @commandsToShow[tab] = []

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

          # if character not set, set it
          if _.isEmpty(@characters)
            # make sure that we get the Listener: {character name} line and not a regular log line
            unless line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)
              if line.indexOf('Listener:') >= 0
                # add Listener character
                c = _.map(line.split(':'), (l) -> return _.trim(l))[1]
                @characters.push c
                console.log 'Added character:', c

          command = ''
          set = ''
          for commandSet, commands of @commandList
            tmp = _.filter(commands, (command) -> return line.indexOf(command) >= 0)
            if tmp.length > 0
              command = tmp[0]
              set = commandSet

          if command.length > 0
            # verify character
            character_name = line.substr(line.indexOf(']')+2, line.indexOf('>')-1-(line.indexOf(']')+2))
            if character_name in @characters

              commandTime = new Date(line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)[0])
              if commandTime.getTime() > @commandTime[set].getTime()
                # if command is after newest command timestamp, save command time and execute command
                @commandTime[set] = commandTime
                value = line.substr(line.indexOf(command)+command.length+1, line.length)

                splits = _.split(value, ',')
                converted = _.map(splits, (s) ->
                  int = _.parseInt(s)
                  if _.isNaN(int)
                    return _.trim(s)
                  else
                    return int
                )

                console.log 'command from', character_name, ':', command, '(set:', set, ')', 'argument', converted

                if command.indexOf('!pcb') >= 0
                  crestService.getBuyPrices(@regionId, converted).then (responses) =>
                    for response in responses
                      price = getTrimmedMean(response.data.items, 0.2)
                      @commands.market.unshift({id: @commands.market.length, time: Date.now(), buyOrder: true, sellOrder: false, name: 'PriceCheckBuy', result: {item: response.data.items[0].type.name, price: price}})
                    onMarketPaginate(@query.market.page, @query.market.limit)
                    @selectedTab = @query.market.tab

                else if command.indexOf('!pcs') >= 0
                  crestService.getSellPrices(@regionId, converted).then (responses) =>
                    for response in responses
                      @commands.market.unshift({id: @commands.market.length, time: Date.now(), buyOrder: false, sellOrder: true, name: 'PriceCheckSell', result: {item: response.data.items[0].type.name, price: getTrimmedMean(response.data.items, 0.2)}})
                    onMarketPaginate(@query.market.page, @query.market.limit)
                    @selectedTab = @query.market.tab

                else if command.indexOf('!thera') >= 0
                  crestService.getTheraInfo(converted[0]).then (response) =>
                    @commands.thera = []
                    for item in response.data
                      @commands.thera.push({id: @commands.thera.length, region: item.destinationSolarSystem.name, system: item.destinationSolarSystem.name, jumps: item.jumps, type: item.destinationWormholeType.name, outSig: item.signatureId, inSig: item.wormholeDestinationSignatureId, estimatedLife: item.wormholeEstimatedEol, updated: item.updatedAt})
                    onTheraPaginate(@query.thera.page, @query.thera.limit)
                    @selectedTab = @query.thera.tab

      fileReader.readAsText file

  onMarketPaginate = (page, limit) =>
    # console.log 'market: page', page, 'limit', limit
    if page != undefined and limit != undefined
      @query.market.page = page
      @query.market.limit = limit
      initial = (page - 1) * limit
      # case 1 - there are enough commands to paginate
      if initial < @commands.market.length
        if @commands.market.length - initial >= limit
          # and there are enough commands left to show at least the limit
          @commandsToShow.market = @commands.market.slice(initial, initial + limit)
        else
          # or there aren't enough, and just show what's left
          @commandsToShow.market = @commands.market.slice(initial, @commands.market.length)
      else
        # case 2 - not enough to paginate
        @commandsToShow.market = @commands.market
      # console.log @query.page, @query.limit, initial, @commandsToShow

  onTheraPaginate = (page, limit) =>
    # console.log 'thera: page', page, 'limit', limit
    if page != undefined and limit != undefined
      @query.thera.page = page
      @query.thera.limit = limit
      initial = (page - 1) * limit
      # case 1 - there are enough commands to paginate
      if initial < @commands.thera.length
        if @commands.thera.length - initial >= limit
          # and there are enough commands left to show at least the limit
          @commandsToShow.thera = @commands.thera.slice(initial, initial + limit)
        else
          # or there aren't enough, and just show what's left
          @commandsToShow.thera = @commands.thera.slice(initial, @commands.thera.length)
      else
        # case 2 - not enough to paginate
        @commandsToShow.thera = @commands.thera
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
  @onMarketPaginate = onMarketPaginate
  @onTheraPaginate = onTheraPaginate
  @onReorder = onReorder
  @removeFilter = removeFilter
  @clearTable = clearTable
  @timeStamp = timeStamp

  return
]
