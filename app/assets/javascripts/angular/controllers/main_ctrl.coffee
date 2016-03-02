app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav', '$state', '$window', 'crestService', '$interval'
  ($scope, $http, $mdSidenav, $state, $window, crestService, $interval) -> do =>
    @version = '0.0.0'
    @user = 
        name: ''
        location: ''
    @interval = null

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

    getUserLocation = =>
      crestService.getUserLocation().then (repsonse) =>
        console.log response
        # @user.location

    init = =>
      @version = '0.0.1'
      crestService.getUser().then (response) =>
        if _.keys(response.data).length > 0
          angular.copy(response.data, @user)
          if @user.hasOwnProperty('characterID')
            @user.image = "https://image.eveonline.com/Character/#{@user.characterID}_64.jpg"
          # cache timer is 10s
          @interval = $interval(getUserLocation, 10000)

    init()

    #-- Public Functions

    @closeSidenav = closeSidenav
    @openSidenav = openSidenav
    @signin = signin
    @signout = signout
    @$state = $state

    return
]
