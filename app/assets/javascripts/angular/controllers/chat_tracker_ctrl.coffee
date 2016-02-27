app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', '$rootScope', 'moment', ($scope, $http, $interval, crestService, $rootScope, moment) -> do =>
  @bookmark = 1
  @selectedTab = 0
  @character = ''

  @file = new File([""], "")
  @interval = null
  @lastMod = @file.lastModifiedDate
  @system = 'Jita'
  @theraOrigin = ''

  @datapointsSm = []
  @datapointsLg = []
  @chartType = 'monthly'
  @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: 'blue'}, {id: 'high', type: 'spline', name: 'High Price', color: 'red'}, {id: 'low', type: 'spline', name: 'Low Price', color: 'green'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#B5FFFC'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#A5FEE3'}]
  @datax = {id: 'date'}
  @marketItem = ''

  @selected =
    market: []
    thera: []
    char: []
    command: []

  @commandTime =
    market: new Date('1969.12.31 18:00:00')
    thera: new Date('1969.12.31 18:00:00')
    char: new Date('1969.12.31 18:00:00')
    command: new Date('1969.12.31 18:00:00')

  @commandList =
    market: ['!market', '!pc', '!system']
    thera: ['!thera']
    char: ['!char', '!allow', '!remove']
    command: ['!commands', '!help']

  @commands =
    market: []
    thera: []
    char: []
    command: []

  @commandsToShow =
    market: []
    thera: []
    char: []
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
    thera:
      filter: '',
      order: '',
      limit: 5,
      page: 1
      tab: 1
    char:
      filter: '',
      order: '',
      limit: 5,
      page: 1
      tab: 2
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
      @datapointsSm = []
      @datapointsLg = []
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
          if _.isEmpty(@commands.char)
            # make sure that we get the Listener: {character name} line and not a regular log line
            unless line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)
              if line.indexOf('Listener:') >= 0
                # add Listener character
                c = _.map(line.split(':'), (l) -> return _.trim(l))[1]
                @commands.char.push {name: c, time: Date.now()}
                onCharPaginate(@query.char.page, @query.char.limit)
                console.log 'Added character:', c
                @character = c

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
            if _.some(@commands.char, (char) -> return _.lowerCase(char.name) == _.lowerCase(character_name))
              commandTime = new Date(line.match(/\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}/)[0])
              if commandTime.getTime() > @commandTime[set].getTime()
                # if command is after newest command timestamp, save command time and execute command
                @commandTime[set] = commandTime
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

                if command.indexOf('!market') >= 0
                  @selectedTab = @query.market.tab

                else if command.indexOf('!char') >= 0
                  @selectedTab = @query.char.tab

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
                      groupsSm = _.groupBy(item.history, (h) -> (moment(h['date']).month() + 1) + ' ' + moment(h['date']).year())
                      groupsLg = _.groupBy(item.history, (h) -> moment(h['date']).week() + ' ' + moment(h['date']).year())
                      resultSm = []
                      resultLg = []
                      for key, val of groupsSm
                        avg = _.mean(_.map(val, (v) -> v['avgPrice']))
                        avgHigh = _.mean(_.map(val, (v) -> v['highPrice']))
                        avgLow = _.mean(_.map(val, (v) -> v['lowPrice']))
                        avgOrder = _.mean(_.map(val, (v) -> v['orderCount']))
                        avgVolume = _.mean(_.map(val, (v) -> v['volume']))
                        resultSm.push({date: moment(key, 'M YYYY').toDate(), avg: avg.toFixed(2), high: avgHigh.toFixed(2), low: avgLow.toFixed(2), order: Math.round(avgOrder), volume: Math.round(avgVolume)})
                      for key, val of groupsLg
                        avg = _.mean(_.map(val, (v) -> v['avgPrice']))
                        avgHigh = _.mean(_.map(val, (v) -> v['highPrice']))
                        avgLow = _.mean(_.map(val, (v) -> v['lowPrice']))
                        avgOrder = _.mean(_.map(val, (v) -> v['orderCount']))
                        avgVolume = _.mean(_.map(val, (v) -> v['volume']))
                        resultLg.push({date: moment(key, 'w YYYY').toDate(), avg: avg.toFixed(2), high: avgHigh.toFixed(2), low: avgLow.toFixed(2), order: Math.round(avgOrder), volume: Math.round(avgVolume)})
                      resultSm = resultSm.sort((a, b) -> new Date(a.date) - new Date(b.date))
                      resultLg = resultLg.sort((a, b) -> new Date(a.date) - new Date(b.date))
                      # reset datapoints arrays
                      @datapointsSm = []
                      @datapointsLg = []
                      for r in resultSm
                        @datapointsSm.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})
                      for r in resultLg
                        @datapointsLg.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})

                else if command.indexOf('!thera') >= 0
                  @theraOrigin = _.upperFirst(converted[0])
                  crestService.getTheraInfo(converted[0]).then (response) =>
                    @commands.thera = []
                    for item in response.data
                      @commands.thera.push({id: @commands.thera.length, region: item.destinationSolarSystem.name, system: item.destinationSolarSystem.name, jumps: item.jumps, type: item.destinationWormholeType.name, outSig: item.signatureId, inSig: item.wormholeDestinationSignatureId, estimatedLife: item.wormholeEstimatedEol, updated: item.updatedAt})
                    onTheraPaginate(@query.thera.page, @query.thera.limit)
                    @selectedTab = @query.thera.tab

                else if command.indexOf('!allow') >= 0
                  @commands.char.unshift {name: converted[0], time: Date.now()}
                  onCharPaginate(@query.char.page, @query.char.limit)
                  @selectedTab = @query.char.tab
                  console.log 'Added character:', converted[0]

                else if command.indexOf('!remove') >= 0
                  if @commands.char.length > 1
                    if converted[0] == 'self'
                      converted[0] = character_name
                    @commands.char = _.filter(@commands.char, (char) -> return _.toLower(char.name) != _.toLower(converted[0]))
                    onCharPaginate(@query.char.page, @query.char.limit)
                    @selectedTab = @query.char.tab
                    console.log @commands.char
                    console.log 'Removed character:', converted[0]
                  else
                    console.log 'Cannot remove last character'

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
        if tab == 'thera' and order.indexOf('jumps') >= 0 and (a[order] == 0 or b[order] == 0) then return -1
        # if tab == 'thera' and order.indexOf('jumps') >= 0 and b[order] == 0 then return -1
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

  onCharPaginate = (page, limit) =>
    onPaginate(page, limit, 'char')

  onCommandPaginate = (page, limit) =>
    onPaginate(page, limit, 'command')

  onMarketReorder = (order) =>
    onReorder(order, 'market')

  onTheraReorder = (order) =>
    onReorder(order, 'thera')

  onCharReorder = (order) =>
    onReorder(order, 'char')

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
    @commands.command.push({name: '!thera', set: 'Thera', argument: '[system name]', description: 'Finds distances to Thera wormholes from given system'})
    @commands.command.push({name: '!char', set: 'Character', argument: '', description: 'Switches to the character tab'})
    @commands.command.push({name: '!allow', set: 'Character', argument: '[character name]', description: 'Adds [character name] to set of characters allowed to use commands'})
    @commands.command.push({name: '!remove', set: 'Character', argument: '[character name] or \'self\'', description: 'Removes [character name] form set of characters allowed to use commands. Removes current character if \'self\''})
    @commands.command.push({name: '!commands', set: 'Command', argument: '', description: 'Switches to the command tab'})
    @commands.command.push({name: '!help', set: 'Command', argument: '', description: 'Switches to the command tab'})
    onCommandPaginate(@query.command.page, @query.command.limit)
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
  @onCharPaginate = onCharPaginate
  @onCommandPaginate = onCommandPaginate
  @onMarketReorder = onMarketReorder
  @onTheraReorder = onTheraReorder
  @onCharReorder = onCharReorder
  @onCommandReorder = onCommandReorder
  @removeFilter = removeFilter
  @clearTable = clearTable
  @priceToIsk = priceToIsk
  @changeChartType = changeChartType

  return
]
