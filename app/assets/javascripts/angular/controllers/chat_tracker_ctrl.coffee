app.controller 'chatTrackerCtrl', ['$scope', '$http', '$interval', 'crestService', '$rootScope', 'moment', ($scope, $http, $interval, crestService, $rootScope, moment) -> do =>
  @bookmark = 1
  @selectedTab = 0
  @listener = ''
  @characters = []

  @file = new File([""], "")
  @interval = null
  @lastMod = @file.lastModifiedDate

  @lastCommandTime = new Date('1969.12.31 18:00:00')

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
    # just grab first word with !
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

      fileReader.readAsText file

  #-- Listeners & Broadcasters

  $scope.$on 'changeTab', (event, arg) =>
    @selectedTab = arg

  $scope.$on 'setCharacters', (event, arg) =>
    @characters = arg

  $scope.$on 'commandListReady', (event, arg) =>
    $scope.$broadcast 'getCommandList'

  # receieve commands from child controllers and rebroadcast to commandCtrl
  $scope.$on 'sendCommandList', (event, arg) =>
    $rootScope.$broadcast 'addCommand', arg

  # flush the shown chart on returning to market screen otherwise axes aren't shown
  $scope.$watch (=> @selectedTab), (newValue, oldValue) =>
    if newValue == 0
      $scope.$broadcast 'flushChart'

  #-- Init

  init = =>
    console.log 'init chartTrackingCtrl'
    return

  init()

  #-- Public Functions

  @setFile = setFile

  return
]
