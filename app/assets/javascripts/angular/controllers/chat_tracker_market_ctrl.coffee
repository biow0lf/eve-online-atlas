app.controller 'chatTrackerMarketCtrl', ['$scope', 'crestService', 'moment', ($scope, crestService, moment) -> do =>

  # datatable variables
  @selected = []
  @commands = []
  @commandsToShow = []
  @query =
    filter: ''
    order: ''
    limit: 5
    page: 1
    tab: 0

  # chart variables
  @datapointsMonthly = []
  @datapointsWeekly = []
  @chartType = 'monthly'
  @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: 'blue'}, {id: 'high', type: 'spline', name: 'High Price', color: 'red'}, {id: 'low', type: 'spline', name: 'Low Price', color: 'green'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#DBEBFF'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#BDFFEA'}]
  @datax = {id: 'date'}
  @marketItem = ''
  @charts = []

  @commandTime = new Date('1969.12.31 18:00:00')
  @system = 'Jita'
  @commandNumber = 0

  executeCommand = (executor, command, argument, time) =>
    toExecute = _.find(@commandsList, {'name': command})
    unless _.isUndefined(toExecute)
      for arg in argument
        toExecute['fn'](executor, arg, time)
        @commandTime = time

  focusTab = =>
    $scope.$emit 'changeTab', @query.tab

  processGroupItems = (group, momentTimeKey) =>
    results = []
    for key, val of group
      avg = _.mean(_.map(val, (v) -> v['avgPrice']))
      avgHigh = _.mean(_.map(val, (v) -> v['highPrice']))
      avgLow = _.mean(_.map(val, (v) -> v['lowPrice']))
      avgOrder = _.mean(_.map(val, (v) -> v['orderCount']))
      avgVolume = _.mean(_.map(val, (v) -> v['volume']))
      results.push({date: moment(key, momentTimeKey).toDate(), avg: avg.toFixed(2), high: avgHigh.toFixed(2), low: avgLow.toFixed(2), order: Math.round(avgOrder), volume: Math.round(avgVolume)})
    return results.sort((a, b) -> new Date(a.date) - new Date(b.date))

  priceCheck = (executor, item, time) =>
    crestService.getPrices(@system, item).then (response) =>
      for item in response.data
        @commandNumber += 1
        @commands.unshift({id: @commandNumber, time: time, item: {name: item.typeName, buy_price: priceToIsk(item.buy_price), sell_price: priceToIsk(item.sell_price), system: item.system}})
        @marketItem = item.typeName
      onPaginate()
    crestService.getHistories(item).then (response) =>
      @datapoints = []
      for item in response.data
        # sort items into month groups
        groupsMonthly = _.groupBy(item.history, (h) -> (moment(h['date']).month() + 1) + ' ' + moment(h['date']).year())
        groupsWeekly = _.groupBy(item.history, (h) -> moment(h['date']).week() + ' ' + moment(h['date']).year())
        resultMonthly = processGroupItems(groupsMonthly, 'M YYYY')
        resultWeekly = processGroupItems(groupsWeekly, 'w YYYY')
        # reset datapoints arrays
        @datapointsMonthly = []
        @datapointsWeekly = []
        for r in resultMonthly
          if moment(r.date).year() >= 2015
            @datapointsMonthly.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})
        for r in resultWeekly
          if moment(r.date).year() >= 2015
            @datapointsWeekly.push({date: r.date, avg: r.avg, high: r.high, low: r.low, order: r.order, volume: r.volume})

  changeSystem = (executor, system) =>
    crestService.isValidSystem(system).then (response) =>
      if response.data != null
        @system = response.data.solarSystemName

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

  clearTable =  =>
    @selected = []
    @commands = []
    @commandsToShow = []
    @datapointsMonthly = []
    @datapointsWeekly = []
    onPaginate()

  changeChartType = =>
    if @chartType == 'monthly'
      @chartType = 'weekly'
    else
      @chartType = 'monthly'

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

  # has to be at the end because otherwise functions wont exist yet
  @commandsList = [
    {
      name: '!market'
      set: 'market'
      argument: ''
      description: 'Switches to the market tab'
      example: '!market'
      fn: focusTab
    }
    {
      name: '!pc'
      set: 'market'
      argument: '{item}'
      description: 'Price checks an item in the current market system; items must be separated by commas or two spaces'
      example: '!pc tritanium | !pc legion, ishtar | !pc oracle  harbinger'
      fn: priceCheck
    }
    {
      name: '!system'
      set: 'market'
      argument: '{system name}'
      description: 'Sets the market system for checking prices. Does not change if argument system is invalid'
      example: '!system jita'
      fn: changeSystem
    }
  ]

  #-- Listeners & Broadcasters

  $scope.$on 'getCommandList', (event, arg) =>
    $scope.$emit 'sendCommandList', @commandsList

  $scope.$on 'command', (event, arg) =>
    # destructure arg
    executeCommand(arg...)

  $scope.$on 'flushChart', (event, arg) =>
    if @chartType is 'monthly'
      @charts[1].flush()
    else if @chartType is 'weekly'
      @charts[0].flush()

  #-- Init

  init = =>
    console.log 'init marketCtrl'
    return

  init()

  #-- Public Functions

  @onPaginate = onPaginate
  @onReorder = onReorder
  @clearTable = clearTable
  @changeChartType = changeChartType
  @handleCallback = handleCallback
  @priceToIsk = priceToIsk

  return
]