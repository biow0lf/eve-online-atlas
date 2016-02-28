app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', '$rootScope', 'moment', ($scope, $http, $interval, crestService, $rootScope, moment) -> do =>
  @bookmark = 1
  @selectedTab = 0
  @listener = ''
  @characters = []

  @file = new File([""], "")
  @interval = null
  @lastMod = @file.lastModifiedDate
  @system = 'Jita'

  @datapointsMonthly = []
  @datapointsWeekly = []
  @chartType = 'monthly'
  @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: 'blue'}, {id: 'high', type: 'spline', name: 'High Price', color: 'red'}, {id: 'low', type: 'spline', name: 'Low Price', color: 'green'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#DBEBFF'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#BDFFEA'}]
  @datax = {id: 'date'}
  @marketItem = ''
  @charts = []

  @lastCommandTime = new Date('1969.12.31 18:00:00')

  @selected =
    market: []
    command: []

  @commandTime =
    market: new Date('1969.12.31 18:00:00')
    command: new Date('1969.12.31 18:00:00')

  @commandList =
    market: ['!market', '!pc', '!system']
    command: ['!commands', '!help']

  @commands =
    market: []
    command: []

  @commandsToShow =
    market: []
    command: []

  @filter = {
    options: {
      debounce: 500
    }
  }

  @query =
    market:
      filter: '',
      order: '',
      limit: 5,
      page: 1
      tab: 0
    command:
      filter: '',
      order: '',
      limit: 5,
      page: 1
      tab: 3

  clearTable = (tab) =>
    @selected[tab] = []
    @commands[tab] = []
    @commandsToShow[tab] = []
    if tab == 'market'
      @datapointsMonthly = []
      @datapointsWeekly = []
    console.log @selected, @commands, @commandsToShow

  changeChartType = =>
    if @chartType == 'monthly'
      @chartType = 'weekly'
    else
      @chartType = 'monthly'

  tick = =>
    currentTime = new Date
    if @file != null && (currentTime.getTime() - @lastMod.getTime()) > 1000  # && @file.lastModifiedDate.getTime() != @lastMod.getTime()
      @lastMod = currentTime
      readFile(@file)

  setFile = (file) =>
    @file = file
    if @interval != null
      $interval.cancel(@interval)
    @interval = $interval(tick, 250)
    return

  priceToIsk = (price) ->
    if price >= 1000000000
      price /= 1000000000
      price = price.toFixed(2).toString() + 'B'
    else if price >= 1000000
      price /= 1000000
      price = price.toFixed(2).toString() + 'M'
    else if price >= 1000
      price /= 1000
      price = price.toFixed(2).toString() + 'K'
    else
      price = price.toFixed(2).toString()
    return price

  handleCallback = (chartObj) =>
    @charts.push(chartObj)

  parseTime = (line) =>
    t = line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)
    unless _.isEmpty(t)
      return new Date(t[0])
    else
      return new Date('1969.12.31 18:00:00')

  parseCharacter = (line) =>
    return line.substr(line.indexOf(']')+2, line.indexOf('>')-1-(line.indexOf(']')+2))

  parseListener = (line) =>
    # can't be the Listener line if there is a date
    return null if line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)
    # must contain Listener: in the line
    return null unless line.indexOf('Listener:') >= 0
    # return everything (trimmed) after the :
    return _.map(line.split(':'), (l) -> return _.trim(l))[1]

  parseCommand = (line) =>
    command = null
    set = null
    for commandSet, commands of @commandList
      tmp = _.filter(commands, (command) -> return line.indexOf(command) >= 0)
      unless _.isEmpty(tmp)
        command = tmp[0]
        set = commandSet
    # otherwise just grab first word with !
    if command == null
      words = _.split(line, ' ')
      for word in words
        if word.indexOf('!') == 0
          command = word
          set = 'blah'
          break

    return [command, set]

  readFile = (file) =>
    if file.size != 0
      fileReader = new FileReader
      fileReader.onload = (e) =>
        text = e.target.result;
        lines = text.split(/[\r\n]+/g); # tolerate both Windows and Unix linebreaks
        for line in lines
          # strip out whitespace on either side
          line = _.trim(line)

          # if listener not set, set it
          if @listener is ''
            listener = parseListener(line)
            unless _.isNull(listener)
              console.log 'Added character:', listener
              @listener = listener
              $scope.$broadcast 'setListener', listener

          # check to see if line contains a command
          [command, set] = parseCommand(line)
          commandTime = parseTime(line)

          if !_.isNull(command) and commandTime.getTime() > @lastCommandTime
            # if command is after newest command timestamp, save command time and execute command
            @lastCommandTime = commandTime
            # verify character
            character_name = parseCharacter(line)
            if character_name in @characters
              value = line.substr(line.indexOf(command)+command.length+1, line.length)
              converted = []

              # two ways to imput items to parse
              # first, by typing in items delimited by comma
              # second, by dragging items to bar there are two spaces between items
              splitChar = null
              if value.indexOf(',') >= 0 then splitChar = ','
              if value.indexOf('  ') >= 0 then splitChar = '  '
              if splitChar != null
                value = _.split(value, splitChar)
                converted = _.map(value, (s) ->
                  int = _.parseInt(s)
                  if _.isNaN(int)
                    return _.trim(s)
                  else
                    return int
                )
              else
                converted = [_.trim(value)]

              console.log 'command from', character_name, ':', command, '(set:', set, ')', 'argument', converted

              # executor, command, argument, time
              $scope.$broadcast 'command', [character_name, command, converted, commandTime]

              if command.indexOf('!market') >= 0
                @selectedTab = @query.market.tab

              else if command.indexOf('!commands') >= 0 or command.indexOf('!help') >= 0
                @selectedTab = @query.command.tab

              else if command.indexOf('!system') >= 0
                crestService.isValidSystem(converted[0]).then (response) =>
                  if response.data != null
                    @system = response.data.solarSystemName

              else if command.indexOf('!pc') >= 0
                crestService.getPrices(@system, converted).then (response) =>
                  for item in response.data
                    @commands.market.unshift({id: @commands.market.length, time: Date.now(), item: {name: item.typeName, buy_price: priceToIsk(item.buy_price), sell_price: priceToIsk(item.sell_price), system: item.system}})
                    @marketItem = item.typeName
                  onMarketPaginate(@query.market.page, @query.market.limit)
                  @selectedTab = @query.market.tab
                crestService.getHistories(converted).then (response) =>
                  @datapoints = []
                  for item in response.data
                    # sort items into month groups
                    groupsMonthly = _.groupBy(item.history, (h) -> (moment(h['date']).month() + 1) + ' ' + moment(h['date']).year())
                    groupsWeekly = _.groupBy(item.history, (h) -> moment(h['date']).week() + ' ' + moment(h['date']).year())
                    resultMonthly = []
                    resultWeekly = []
                    for key, val of groupsMonthly
                      avg = _.mean(_.map(val, (v) -> v['avgPrice']))
                      avgHigh = _.mean(_.map(val, (v) -> v['highPrice']))
                      avgLow = _.mean(_.map(val, (v) -> v['lowPrice']))
                      avgOrder = _.mean(_.map(val, (v) -> v['orderCount']))
                      avgVolume = _.mean(_.map(val, (v) -> v['volume']))
                      resultMonthly.push({date: moment(key, 'M YYYY').toDate(), avg: avg.toFixed(2), high: avgHigh.toFixed(2), low: avgLow.toFixed(2), order: Math.round(avgOrder), volume: Math.round(avgVolume)})
                    for key, val of groupsWeekly
                      avg = _.mean(_.map(val, (v) -> v['avgPrice']))
                      avgHigh = _.mean(_.map(val, (v) -> v['highPrice']))
                      avgLow = _.mean(_.map(val, (v) -> v['lowPrice']))
                      avgOrder = _.mean(_.map(val, (v) -> v['orderCount']))
                      avgVolume = _.mean(_.map(val, (v) -> v['volume']))
                      resultWeekly.push({date: moment(key, 'w YYYY').toDate(), avg: avg.toFixed(2), high: avgHigh.toFixed(2), low: avgLow.toFixed(2), order: Math.round(avgOrder), volume: Math.round(avgVolume)})
                    resultMonthly = resultMonthly.sort((a, b) -> new Date(a.date) - new Date(b.date))
                    resultWeekly = resultWeekly.sort((a, b) -> new Date(a.date) - new Date(b.date))
                    # reset datapoints arrays
                    @datapointsMonthly = []
                    @datapointsWeekly = []
                    for r in resultMonthly
                      if moment(r.date).year() >= 2015
                        @datapointsMonthly.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})
                    for r in resultWeekly
                      if moment(r.date).year() >= 2015
                        @datapointsWeekly.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})

      fileReader.readAsText file

  onPaginate = (page, limit, tab) =>
    # console.log 'market: page', page, 'limit', limit
    if page != undefined and limit != undefined
      @query[tab].page = page
      @query[tab].limit = limit
      initial = (page - 1) * limit
      # case 1 - there are enough commands to paginate
      if initial < @commands[tab].length
        if @commands[tab].length - initial >= limit
        # and there are enough commands left to show at least the limit
          @commandsToShow[tab] = @commands[tab].slice(initial, initial + limit)
        else
        # or there aren't enough, and just show what's left
          @commandsToShow[tab] = @commands[tab].slice(initial, @commands[tab].length)
      else
      # case 2 - not enough to paginate
        @query[tab].page = 1
        @commandsToShow[tab] = @commands[tab]
        # console.log @query.page, @query.limit, initial, @commandsToShow

  onReorder = (order, tab) =>
    if order.indexOf('-') >= 0
      order = order.substr(1, order.length)
      @commands[tab].sort((a, b) ->
        if a[order] < b[order] then return -1
        if a[order] > b[order] then return 1
        return 0
      ).reverse()
    else
      @commands[tab].sort((a, b) ->
        if a[order] < b[order] then return -1
        if a[order] > b[order] then return 1
        return 0
      )
    onPaginate(@query[tab].page, @query[tab].limit, tab)
    return

  onMarketPaginate = (page, limit) =>
    onPaginate(page, limit, 'market')

  onTheraPaginate = (page, limit) =>
    onPaginate(page, limit, 'thera')

  onCommandPaginate = (page, limit) =>
    onPaginate(page, limit, 'command')

  onMarketReorder = (order) =>
    onReorder(order, 'market')

  onTheraReorder = (order) =>
    onReorder(order, 'thera')

  onCommandReorder = (order) =>
    onReorder(order, 'command')

  removeFilter = =>
    # @filter.show = false
    @query.filter = ''

  init = =>
    console.log 'initializing'
    @commands.command.push({name: '!market', set: 'Market', argument: '', description: 'Switches to the market tab'})
    @commands.command.push({name: '!pc', set: 'Market', argument: 'List of item names separated by comma or doublespace', description: 'Price checks an item in the current market system'})
    @commands.command.push({name: '!system', set: 'Market', argument: '[system name]', description: 'Sets the current market system for checking prices. Does not change if system name is invalid.'})
    @commands.command.push({name: '!commands', set: 'Command', argument: '', description: 'Switches to the command tab'})
    @commands.command.push({name: '!help', set: 'Command', argument: '', description: 'Switches to the command tab'})
    onCommandPaginate(@query.command.page, @query.command.limit)
    return

  init()

  $scope.$on 'changeTab', (event, arg) =>
    @selectedTab = arg

  $scope.$on 'setCharacters', (event, arg) =>
    @characters = arg

  # flush the shown chart on returning to market screen otherwise axes aren't shown
  $scope.$watch (=> @selectedTab), (newValue, oldValue) =>
    if newValue == 0 && @charts.length == 2
      if @chartType == 'monthly'
        console.log 'flushed monthly'
        @charts[1].flush()
      else if @chartType == 'weekly'
        console.log 'flushed weekly'
        @charts[0].flush()

  test = =>
    $scope.$broadcast 'command', ['someone', 'someCmd', ['arg0'], Date.now()]

  #-- Public Functions

  @setFile = setFile
  @onMarketPaginate = onMarketPaginate
  @onCommandPaginate = onCommandPaginate
  @onMarketReorder = onMarketReorder
  @onCommandReorder = onCommandReorder
  @removeFilter = removeFilter
  @clearTable = clearTable
  @priceToIsk = priceToIsk
  @changeChartType = changeChartType
  @handleCallback = handleCallback
  @test = test

  return
]
