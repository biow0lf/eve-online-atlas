app.controller 'chatTrackerCommandCtrl', ['$scope', ($scope) -> do =>

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

  onPaginate = (page, limit) =>
  # console.log 'commands: page', page, 'limit', limit
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