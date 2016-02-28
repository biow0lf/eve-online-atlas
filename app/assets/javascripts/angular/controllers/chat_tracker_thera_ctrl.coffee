app.controller 'chatTrackerTheraCtrl', ['$scope', '$http', 'crestService', ($scope, $http, crestService) -> do =>

  init = =>
    return

  init()

  $scope.$on 'command', (event, arg) =>
    console.log 'trying to execute from thera', event, arg

  #-- Public Functions

  return
]