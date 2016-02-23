app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', '$rootScope', ($scope, $http, $interval, crestService, $rootScope) -> do =>
  @bookmark = 1
  @selectedTab = 0
  @characters = []

  @file = new File([""], "")
  @interval = null
  @lastMod = @file.lastModifiedDate
  @system = 'Jita'
  @theraOrigin = ''

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
    market: ['!market', '!pc', '!marketsystem']
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
    console.log @selected, @commands, @commandsToShow

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
                @selectedTab = @query.char.tab
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

                else if command.indexOf('!marketsystem') >= 0
                  crestService.isValidSystem(converted[0]).then (response) =>
                    if response.data != null
                      @system = response.data.solarSystemName

                else if command.indexOf('!pc') >= 0
                  crestService.getPrices(@system, converted).then (response) =>
                    for item in response.data
                      @commands.market.unshift({id: @commands.market.length, time: Date.now(), item: {name: item.typeName, buy_price: item.buy_price, sell_price: item.sell_price, system: item.system}})
                    onMarketPaginate(@query.market.page, @query.market.limit)
                    @selectedTab = @query.market.tab

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
    @commands.command.push({name: '!marketsystem', set: 'Market', argument: '[system name]', description: 'Sets the current market system for checking prices. Does not change if system name is invalid.'})
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
  @timeStamp = timeStamp

  return
]
