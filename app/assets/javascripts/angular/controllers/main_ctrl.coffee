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

    signout = =>
      crestService.signout().then (response) =>
        @user =
          name: ''

    init = =>
      @version = '0.0.1'
      crestService.getUser().then (response) =>
        if _.keys(response.data).length > 0
          angular.copy(response.data, @user)
          if @user.hasOwnProperty('characterID')
            @user.image = "https://image.eveonline.com/Character/#{@user.characterID}_64.jpg"

    init()

    #-- Public Functions

    @closeSidenav = closeSidenav
    @openSidenav = openSidenav
    @signin = signin
    @signout = signout
    @$state = $state

    return
]
