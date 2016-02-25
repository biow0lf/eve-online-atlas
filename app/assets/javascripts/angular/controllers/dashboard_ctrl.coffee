app.controller 'dashboardCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>
  @solarSystemID = 30000001
  @systemName = 'Jita'

  crestService.getSolarSystem(@solarSystemID).then (response) => console.log response

  return
]