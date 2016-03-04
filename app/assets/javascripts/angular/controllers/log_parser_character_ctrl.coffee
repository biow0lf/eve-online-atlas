app.controller 'logParserCharacterCtrl', ['$scope', 'utilsService', ($scope, utilsService) -> do =>

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
    unless character.name.toLowerCase() in @characterNames
      @commands.unshift({name: character.name.toLowerCase(), time: Date.now()})
    @characterNames = (c.name for c in @commands)
    $scope.$emit 'setCharacters', @characterNames
    onPaginate()
    focusTab()

  removeCharacter = (executor, character) =>
    if character.name.toLowerCase() is 'all'
      @commands = [{name: @listener, time: Date.now()}]
    else if character.name.toLowerCase() is 'self'
      # this mutates the @commands array
      _.remove(@commands, (c) => c.name isnt @listener and c.name is executor)
    else
      # this mutates the @commands array
      _.remove(@commands, (c) => c.name isnt @listener and c.name is character.name.toLowerCase())
    @characterNames = (c.name for c in @commands)
    $scope.$emit 'setCharacters', @characterNames
    onPaginate()

  onPaginate = (page, limit) =>
    [@commandsToShow, @query.page] = utilsService.paginate(@commands, page || @query.page, limit || @query.limit)

  onReorder = (order) =>
    @commands = utilsService.reorder(@commands, order)
    onPaginate()

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!char'
      set: 'character'
      argument: ''
      description: 'Switches to the character tab'
      example: '!char'
      fn: focusTab
    }
    {
      name: '!allow'
      set: 'character'
      argument: '{character name}'
      description: 'Adds [character name] to set of characters allowed to use commands; multiple names must be separated by commas or two spaces'
      example: '!allow Aes Sayyadina' +
        '\n!allow Aes Sayyadina, Blacksmoke16' +
        '\n!allow Aes Sayyadina  Blacksmoke16'
      fn: allowCharacter
    }
    {
      name: '!remove'
      set: 'character'
      argument: '{character name} | \'self\' | \'all\''
      description: 'Removes [character name] from set of characters allowed to use commands; multiple names must be separated by commas or two spaces; removes current character if \'self\'; removes all but listener if \'all\''
      example: '!remove Aes Sayyadina' +
        '\n!remove Aes Sayyadina, Blacksmoke16' +
        '\n!remove Aes Sayyadina  Blacksmoke16' +
        '\n!remove self' +
        '\n!remove all'
      fn: removeCharacter
    }
  ]

  #-- Listeners & Broadcasters

  $scope.$on 'getCommandList', (event, arg) =>
    $scope.$emit 'sendCommandList', @commandsList

  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  $scope.$on 'setListener', (event, arg) =>
    @listener = arg
    @commands.unshift({name: @listener, time: Date.now()})
    @characterNames = [@listener]
    onPaginate()
    $scope.$emit 'setCharacters', @characterNames

  #-- init

  init = =>
    console.log 'init characterCtrl'
    return

  init()

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder

  return
]