app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav', '$state', '$window', 'crestService',
  ($scope, $http, $mdSidenav, $state, $window, crestService) -> do =>
    @version = '0.0.0'
    @user = 
        name: ''

    closeSidenav = (componentId) =>
      $mdSidenav(componentId).close()

    openSidenav = (componentId) =>
      $mdSidenav(componentId).open()

    signin = =>
      $window.location.href = '/auth/crest'

    init = =>
      @version = '0.0.1'
      crestService.getUser().then (response) =>
        angular.copy(response.data, @user)

    init()

    #-- Public Functions

    @closeSidenav = closeSidenav
    @openSidenav = openSidenav
    @signin = signin

    return
]
