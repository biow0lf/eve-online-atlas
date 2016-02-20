app.controller 'mainCtrl', ['$scope', '$http', '$mdSidenav',
  ($scope, $http, $mdSidenav) -> do =>
    @version = '0.0.0'

    do_post = =>
      return
#      $http({
#        method: 'GET',
#        url: 'users/permissions',
#      }).then((response) =>
#        console.log('response: ', response)
#      )
#      permissions = ['manage_account_subscription', 'manage_employees', 'manage_users', 'post_jobs',
#        'view_all_jobs_and_candidates']
#
#      for permission in permissions
#        Session.hasPermission(permission).then((response)=>
#          console.log 'has permission', permission
#        ).catch((response)=>
#          console.log 'does not have permission', permission
#        )

    closeSidenav = (componentId) =>
      $mdSidenav(componentId).close()

    openSidenav = (componentId) =>
      $mdSidenav(componentId).open()

    init = =>
      @version = '0.0.1'

    init()

    #-- Public Functions

    @do_post = do_post
    @closeSidenav = closeSidenav
    @openSidenav = openSidenav

    return

]
