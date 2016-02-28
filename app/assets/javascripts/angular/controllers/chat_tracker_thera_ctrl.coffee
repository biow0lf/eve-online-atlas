app.controller 'chatTrackerTheraCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>

  # datatable variables
  @selected = []
  @commands = []
  @commandsToShow = []
  @query =
    filter: ''
    order: ''
    limit: 5
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

  findThera = (executor, system) =>
    crestService.getTheraInfo(system).then (response) =>
      @commands.thera = []
      for item in response.data
        @commands.push({id: @commands.thera.length, region: item.destinationSolarSystem.name, system: item.destinationSolarSystem.name, jumps: item.jumps, type: item.destinationWormholeType.name, outSig: item.signatureId, inSig: item.wormholeDestinationSignatureId, estimatedLife: item.wormholeEstimatedEol, updated: item.updatedAt})
      @theraOrigin = _.upperFirst(system)
      onPaginate()
      focusTab()

  onPaginate = (page, limit) =>
    # console.log 'thera: page', page, 'limit', limit
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
    console.log 'theraCtrl init'
    return

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!thera'
      argument: '{system name}'
      description: 'Switches to the thera tab and finds distances to Thera wormholes from given system'
      example: '!thera Jita'
      fn: findThera
    }
  ]

  init()

  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder

  return
]