app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav', '$state',
  ($scope, $http, $mdSidenav, $state) -> do =>
    @version = '0.0.0'

    closeSidenav = (componentId) =>
      $mdSidenav(componentId).close()

    openSidenav = (componentId) =>
      $mdSidenav(componentId).open()

    init = =>
      @version = '0.0.1'

    init()

    #-- Public Functions

    @closeSidenav = closeSidenav
    @openSidenav = openSidenav

    return

]
