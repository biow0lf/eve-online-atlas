app.controller 'logParserTheraCtrl', ['$scope', 'crestService', 'utilsService', '$state', ($scope, crestService, utilsService, $state) -> do =>

  # datatable variables
  @selected = []
  @commands = []
  @commandsToShow = []
  @query =
    filter: ''
    order: ''
    limit: 10
    page: 1
    tab: 1

  @commandTime = new Date('1969.12.31 18:00:00')
  @theraOrigin = ''

  executeCommand = (executor, command, argument, time) =>
    toExecute = _.find(@commandsList, {'name': command})
    unless _.isUndefined(toExecute)
      for arg in argument
        toExecute['fn'](executor, arg)
        @commandTime = time

  focusTab = =>
    $scope.$emit 'changeTab', @query.tab
    $state.go('root.log_parser') unless $state.current.name is 'root.log_parser'

  findThera = (executor, system) =>
    systemName = ''
    if system.hasOwnProperty('name')
      systemName = system.name
    crestService.getTheraInfo(systemName).then (response) =>
      @commands = []
      for item in response.data
        @commands.push({id: @commands.length, region: item.destinationSolarSystem.region.name, system: item.destinationSolarSystem.name, jumps: item.jumps, type: item.destinationWormholeType.name, outSig: item.signatureId, inSig: item.wormholeDestinationSignatureId, estimatedLife: item.wormholeEstimatedEol, updated: item.updatedAt})
      @theraOrigin = _.upperFirst(systemName)
      onPaginate()
      focusTab()

  onPaginate = (page, limit) =>
    [@commandsToShow, @query.page] = utilsService.paginate(@commands, page || @query.page, limit || @query.limit)

  onReorder = (order) =>
    @commands = utilsService.reorder(@commands, order)
    onPaginate()

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!thera'
      set: 'thera'
      argument: '{system name}'
      description: 'Switches to the thera tab and finds distances to Thera wormholes from given system'
      example: '!thera Jita'
      fn: findThera
    }
  ]

  #-- Listeners & Broadcasters

  $scope.$on 'getCommandList', (event, arg) =>
    $scope.$emit 'sendCommandList', @commandsList

  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  #-- Init

  init = =>
    console.log 'init theraCtrl'
    return

  init()

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder

  return
]