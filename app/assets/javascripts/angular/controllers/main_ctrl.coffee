app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav', '$state', '$window', 'crestService', '$interval', 'userService',
  ($scope, $http, $mdSidenav, $state, $window, crestService, $interval, userService) -> do =>
    @version = '0.0.0'
    @user = userService.user
    @interval = null

    closeSidenav = (componentId) =>
      $mdSidenav(componentId).close()

    openSidenav = (componentId) =>
      $mdSidenav(componentId).open()

    signin = =>
      $window.location.href = '/auth/crest'

    signout = =>
      crestService.signout().then (response) =>
        if @interval != null
          $interval.cancel(@interval)
        angular.copy({ name: '', location: ''}, userService.user)

    getUserLocation = =>
      crestService.getUserLocation().then (response) =>
        console.log response
        angular.merge({}, userService.user.solarSystem, response.data.solarSystem)

    init = =>
      @version = '0.0.1'
      crestService.getUser().then (response) =>
        if _.keys(response.data).length > 0
          angular.merge({}, userService.user, response.data)
          console.log 'service', userService.user
          console.log 'user', @user
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
