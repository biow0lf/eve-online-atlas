app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', 'userService', 'mapGraph', ($scope, $http, crestService, userService, mapGraph) -> do =>
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

  @map = undefined

  indexToPercent = (index) ->
    return (index * 10).toFixed(2).toString()

  noTick = (tick) ->
    return ''

  handleCallback = (chartObj) =>
    @charts.push(chartObj)

  changeSystem = (system) =>
    @solarSystemID = system
    crestService.getSolarSystem(@solarSystemID).then (response) =>
      @moonData = []
      @indexData = []
      @systemData = []
      @neighbors = []

      @systemData = response.data
      for planetID in @systemData['planetIDs']
        crestService.getMoon(@solarSystemID, planetID).then (response) =>
          for item in response.data
            @moonData.push(item)
        @indexData.push({
          index: 0,
          manufacturing: @systemData.costIndexes.manufacturingIndex0,
          researchMaterial: @systemData.costIndexes.materialResearchIndex,
          researchTime: @systemData.costIndexes.timeResearchIndex,
          invention: @systemData.costIndexes.inventionIndex,
          copying: @systemData.costIndexes.copyingIndex})
      # getAgentData()
      crestService.getNeighboringSystems(@solarSystemID).then (response) =>
        @neighbors = response.data

        mapGraph(_.concat(@systemData, @neighbors)).then (response) =>
          @map = response

    crestService.getPlanet(@solarSystemID).then (response) =>
      @planetData = response.data
    #console.log @planetData
    crestService.getStation(@solarSystemID).then (response) =>
      @stationData = response.data
    return

  init = =>
    crestService.getSolarSystem(@solarSystemID).then (response) =>
      @systemData = response.data
      for planetID in @systemData['planetIDs']
        crestService.getMoon(@solarSystemID, planetID).then (response) =>
          for item in response.data
            @moonData.push(item)
        @indexData.push({
          index: 0,
          manufacturing: @systemData.costIndexes.manufacturingIndex,
          researchMaterial: @systemData.costIndexes.materialResearchIndex,
          researchTime: @systemData.costIndexes.timeResearchIndex,
          invention: @systemData.costIndexes.inventionIndex,
          copying: @systemData.costIndexes.copyingIndex})
      # getAgentData()
      crestService.getNeighboringSystems(@solarSystemID).then (response) =>
        @neighbors = response.data
        mapGraph(_.concat(@systemData, @neighbors)).then (response) =>
          @map = response

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

  $scope.$watchCollection (=> @user.solarSystem), (newValue, oldValue) =>
    if newValue.hasOwnProperty('id') and oldValue.hasOwnProperty('id')
      if newValue.id != oldValue.id and !_.isNaN(newValue)
        changeSystem(newValue.id)

  #-- Public Functions

  @indexToPercent = indexToPercent
  @noTick = noTick
  @handleCallback = handleCallback

  return
]