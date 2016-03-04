app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', 'userService', ($scope, $http, crestService, userService) -> do =>
  @solarSystemID = 30000001
  @systemData = []
  @planetData = []
  @moonData = []
  @stationData = []
  @selectedTab = 0
  @neighbors = []

  @user = userService.user

  @indexData = []
  @datacolumns = [{id: 'manufacturing', type: 'bar', name: 'Manufacturing', color: 'blue'},
    {id: 'researchMaterial', type: 'bar', name: 'Research Material', color: 'red'},
    {id: 'researchTime', type: 'bar', name: 'Research Time', color: 'green'},
    {id: 'invention', type: 'bar', name: 'Invention', color: 'yellow'},
    {id: 'copying', type: 'bar', name: 'Copying', color: 'purple'}]
  @datax = {id: 'index'}
  @charts = []

  indexToPercent = (index) ->
    return (index * 10).toFixed(2).toString()

  noTick = (tick) ->
    return ''

  handleCallback = (chartObj) =>
    @charts.push(chartObj)

  init = =>
    crestService.getSolarSystem(@solarSystemID).then (response) =>
      @systemData = response.data
      for planetID in @systemData['planetIDs']
        crestService.getMoon(@solarSystemID, planetID).then (response) =>
          for item in response.data
            @moonData.push(item)
        @indexData.push({
          index: 0,
          manufacturing: @systemData.costIndexes.manufacturingIndex*10,
          researchMaterial: @systemData.costIndexes.materialResearchIndex*10,
          researchTime: @systemData.costIndexes.timeResearchIndex*10,
          invention: @systemData.costIndexes.inventionIndex*10,
          copying: @systemData.costIndexes.copyingIndex*10})
    crestService.getNeighboringSystems(@solarSystemID).then (response) =>
        @neighbors = response.data
      # getAgentData()
    crestService.getPlanet(@solarSystemID).then (response) =>
      @planetData = response.data
      #console.log @planetData
    crestService.getStation(@solarSystemID).then (response) =>
      @stationData = response.data
    return

  init()

  # flush the shown chart on returning to market screen otherwise axes aren't shown
  $scope.$watch (=> @selectedTab), (newValue, oldValue) =>
    if newValue == 0 and @charts.length > 0
      @charts[0].flush()


  #-- Public Functions

  @indexToPercent = indexToPercent
  @noTick = noTick
  @handleCallback = handleCallback

  return
]