app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>
  @solarSystemID = 30000001
  @systemData = {}
  @planetData = []
  @stationData = []
  @selectedPlanet = {}
  @selectedStation = {}


  crestService.getSolarSystem(@solarSystemID).then (response) =>
    if response != null
      @systemData = response.data
      getPlanetData(@solarSystemID,item) for item in @systemData['planetIDs']
      getStationData(@solarSystemID,item) for item in @systemData['stationIDs']
     # getAgentData()

  getPlanetData = (solarSystemID,planetID) =>
    crestService.getPlanet(solarSystemID, planetID).then (response) =>
      if response != null
        @planetData.push(response.data)
        #console.log @planetData

  getStationData = (solarSystemID,stationID) =>
    crestService.getStation(solarSystemID, stationID).then (response) =>
      if response != null
        @stationData.push(response.data)
        console.log @stationData

  selectPlanet = (index) =>
    @selectedPlanet = @planetData[index]

  selectStation = (index) =>
    @selectedStation = @stationData[index]


  @selectPlanet = selectPlanet
  @selectStation = selectStation


  return
]