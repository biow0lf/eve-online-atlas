app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>
  @solarSystemID = 30000001
  @systemName = 'Jita'
  @constellationName = 'Kimotoro'
  @regionName = 'The Forge'

  @systems = []

  for idx in [0..5]
    @systems.push({name: "System #{idx}"})

  crestService.getSolarSystem(@solarSystemID).then (response) => console.log response

  return
]