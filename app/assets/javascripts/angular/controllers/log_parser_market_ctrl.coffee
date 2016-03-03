app.controller 'logParserMarketCtrl', ['$scope', 'crestService', 'moment', 'utilsService', ($scope, crestService, moment, utilsService) -> do =>

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

  # orders-light: #DBEBFF
  # volumne-light: #BDFFEA
  # orders-dark: #2b5797
  # volume-dark: #1e7145

  # chart variables
  @datapointsMonthly = []
  @datapointsWeekly = []
  @chartType = 'monthly'
  # @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: '#810099'}, {id: 'high', type: 'spline', name: 'High Price', color: '#998100'}, {id: 'low', type: 'spline', name: 'Low Price', color: '#009981'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#1b3249'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#7e570a'}]
  # Karlyn : 17
  # @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: '#F1F0EA'}, {id: 'high', type: 'spline', name: 'High Price', color: '#F7CE3D'}, {id: 'low', type: 'spline', name: 'Low Price', color: '#38AFFC'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#948076'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#BFC766'}]
  # Graus Arquitectura Técnia : 21
  # @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: '#6F97B2'}, {id: 'high', type: 'spline', name: 'High Price', color: '#FE6800'}, {id: 'low', type: 'spline', name: 'Low Price', color: '#1B3067'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#988E87'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#342E2A'}]
  @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: '#F1F0EA'}, {id: 'high', type: 'spline', name: 'High Price', color: '#F7CE3D'}, {id: 'low', type: 'spline', name: 'Low Price', color: '#38AFFC'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#1B3067'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#342E2A'}]
  # @datacolumns = [{id: 'avg', type: 'spline', name: 'Avg. Price', color: '#3F9852'}, {id: 'high', type: 'spline', name: 'High Price', color: '#DA7E30'}, {id: 'low', type: 'spline', name: 'Low Price', color: '#3869B1'}, {id: 'order', type: 'bar', name: 'Order Count', color: '#818787'}, {id: 'volume', type: 'bar', name: 'Volume', color: '#CCC374'}]
  @datax = {id: 'date'}
  @marketItem = ''
  @charts = []

  @commandTime = new Date('1969.12.31 18:00:00')
  @system = 'Jita'
  @region = ''
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
    itemName = ''
    itemQuantity = 1
    if item.hasOwnProperty('name')
      itemName = item.name
    if item.hasOwnProperty('quantity')
      itemQuantity = item.quantity

    crestService.getPrices(@system, @region, itemName).then (response) =>
      if _.isEmpty(@system)
        # prices came from region
        for responseItem in response.data
          @commandNumber += 1
          @commands.unshift({id: @commandNumber, time: time, item: {name: responseItem.typeName, quantity: itemQuantity, unit_buy: priceToIsk(responseItem.buy_price), unit_sell: priceToIsk(responseItem.sell_price), buy_price: priceToIsk(responseItem.buy_price * itemQuantity), sell_price: priceToIsk(responseItem.sell_price * itemQuantity), system: responseItem.region}})
      else
        for responseItem in response.data
          @commandNumber += 1
          @commands.unshift({id: @commandNumber, time: time, item: {name: responseItem.typeName, quantity: itemQuantity, unit_buy: priceToIsk(responseItem.buy_price), unit_sell: priceToIsk(responseItem.sell_price), buy_price: priceToIsk(responseItem.buy_price * itemQuantity), sell_price: priceToIsk(responseItem.sell_price * itemQuantity), system: responseItem.system}})
      onPaginate()
      focusTab()

    crestService.getHistories(itemName).then (response) =>
      @datapoints = []
      @marketItem = itemName
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
    crestService.isValidSystem(system.name).then (response) =>
      @system = response.data.solarSystemName
      @region = ''
      focusTab()

  changeRegion = (executor, region) =>
    crestService.isValidRegion(region.name).then (response) =>
      @region = response.data.regionName
      @system = ''
      focusTab()

  onPaginate = (page, limit) =>
    [@commandsToShow, @query.page] = utilsService.paginate(@commands, page || @query.page, limit || @query.limit)

  onReorder = (order) =>
    @commands = utilsService.reorder(@commands, order)
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
      description: 'Price checks an item in the current market system; items must be separated by commas or two spaces, or be pasted from an inventory'
      example: '!pc tritanium' +
        '\n!pc legion, ishtar' +
        '\n!pc oracle  harbinger' +
        '\n!pc legion@10, ishtar@5'
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
    {
      name: '!region'
      set: 'market'
      argument: '{region name}'
      description: 'Sets the market region for checking prices. Does not change if argument region is invalid'
      example: '!region the forge'
      fn: changeRegion
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