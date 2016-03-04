app.controller 'logParserCommandCtrl', ['$scope', 'utilsService', '$state', ($scope, utilsService, $state) -> do =>

  # datatable variables
  @selected = []
  @commands = []
  @commandsToShow = []
  @query =
    filter: ''
    order: ''
    limit: 5
    page: 1
    tab: 3

  @commandTime = new Date('1969.12.31 18:00:00')

  executeCommand = (executor, command, argument, time) =>
    toExecute = _.find(@commandsList, {'name': command, set: 'commands'})
    unless _.isUndefined(toExecute)
      for arg in argument
        toExecute['fn'](executor, arg)
        @commandTime = time

  focusTab = =>
    $scope.$emit 'changeTab', @query.tab
    $state.go('root.log_parser') unless $state.current.name is 'root.log_parser'

  onPaginate = (page, limit) =>
    [@commandsToShow, @query.page] = utilsService.paginate(@commands, page || @query.page, limit || @query.limit)

  onReorder = (order) =>
    @commands = utilsService.reorder(@commands, order)
    onPaginate()

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!commands'
      set: 'commands'
      argument: ''
      description: 'Switches to the command tab'
      example: '!commands'
      fn: focusTab
    }
    {
      name: '!help'
      set: 'commands'
      argument: ''
      description: 'Switches to the command tab'
      example: '!help'
      fn: focusTab
    }
  ]

  #-- Listeners & Broadcasters

  $scope.$on 'addCommand', (event, arg) =>
    for cmd in arg
      @commands.push(cmd)
    onPaginate()

  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  #-- Init

  init = =>
    console.log 'init commandCtrl'
    angular.copy(@commandsList, @commands)
    onPaginate()
    $scope.$emit 'commandListReady'
    return

  init()

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder

  return
]