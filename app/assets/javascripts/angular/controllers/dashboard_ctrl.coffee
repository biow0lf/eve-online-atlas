app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>
  @solarSystemID = 30000001
  @systemName = 'Jita'
  @constellationName = 'Kimotoro'
  @regionName = 'The Forge'

  @celestials = []

  for idx in [0..5]
    @celestials.push({name: "Celestial #{idx}"})

  crestService.getSolarSystem(@solarSystemID).then (response) => console.log response

  return
]