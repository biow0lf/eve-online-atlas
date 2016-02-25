app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav', '$state', '$window',
  ($scope, $http, $mdSidenav, $state, $window) -> do =>
    @version = '0.0.0'

    closeSidenav = (componentId) =>
      $mdSidenav(componentId).close()

    openSidenav = (componentId) =>
      $mdSidenav(componentId).open()

    signin = =>
      console.log 'going to /auth/crest'
      $window.location.href = '/auth/crest'

    init = =>
      @version = '0.0.1'

    init()

    #-- Public Functions

    @closeSidenav = closeSidenav
    @openSidenav = openSidenav
    @signin = signin

    return
]
