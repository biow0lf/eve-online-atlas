app.controller 'chatTrackerCharacterCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>

  # datatable variables
  @selected = []
  @commands = []
  @commandsToShow = []
  @query =
    filter: ''
    order: ''
    limit: 5
    page: 1
    tab: 2

  # state control
  @commandTime = new Date('1969.12.31 18:00:00')
  @listener = ''
  @characterNames = []

  executeCommand = (executor, command, argument, time) =>
    toExecute = _.find(@commandsList, {'name': command})
    unless _.isUndefined(toExecute)
      for arg in argument
        toExecute['fn'](executor, arg)
        @commandTime = time

  focusTab = =>
    $scope.$emit 'changeTab', @query.tab

  allowCharacter = (executor, character) =>
    unless character in @characterNames
      @commands.unshift({name: character, time: Date.now()})
    @characterNames = (c.name for c in @commands)
    $scope.$emit 'setCharacters', @characterNames
    onPaginate()
    focusTab()

  removeCharacter = (executor, character) =>
    if character is 'all'
      @commands = [{name: @listener, time: Date.now()}]
    else if character is 'self'
      # this mutates the @commands array
      _.remove(@commands, (c) => c.name isnt @listener and c.name is executor)
    else
      # this mutates the @commands array
      _.remove(@commands, (c) => c.name isnt @listener and c.name is character)
    @characterNames = (c.name for c in @commands)
    $scope.$emit 'setCharacters', @characterNames
    onPaginate()

  onPaginate = (page, limit) =>
    # console.log 'market: page', page, 'limit', limit
    if page is undefined
      page = @query.page
    else
      @query.page = page
    if limit is undefined
      limit = @query.limit
    else
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
      # case 2 - not enough to paginate, so decrement page and try again
      onPaginate(page - 1, limit)

  onReorder = (order) =>
    reverse = false
    if order.indexOf('-') >= 0
      order = _.replace(order, '-', '')
      reverse = true
    @commands.sort (a, b) ->
      if a[order] < b[order] then return -1
      if a[order] > b[order] then return 1
      return 0
    @commands.reverse() if reverse
    onPaginate()

  init = =>
    console.log 'ctcc init'
    return

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!char'
      argument: ''
      description: 'Switches to the character tab'
      example: '!char'
      fn: focusTab
    }
    {
      name: '!allow'
      argument: '{character name}'
      description: 'Adds [character name] to set of characters allowed to use commands; multiple names must be separated by commas or two spaces'
      example: '!allow Aes Sayyadina | !allow Aes Sayyadina, Blacksmoke16 | !allow Aes Sayyadina  Blacksmoke16'
      fn: allowCharacter
    }
    {
      name: '!remove'
      argument: '{character name} or \'self\''
      description: 'Removes [character name] from set of characters allowed to use commands; multiple names must be separated by commas or two spaces; removes current character if \'self\'; removes all but listener if \'all\''
      example: '!remove Aes Sayyadina | !remove Aes Sayyadina, Blacksmoke16 | !remove Aes Sayyadina  Blacksmoke16 | !remove self | !remove all'
      fn: removeCharacter
    }
  ]

  init()

  #-- Listeners
  
  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  $scope.$on 'setListener', (event, arg) =>
    @listener = arg
    @commands.unshift({name: @listener, time: Date.now()})
    @characterNames = [@listener]
    onPaginate()
    $scope.$emit 'setCharacters', @characterNames

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder

  return
]