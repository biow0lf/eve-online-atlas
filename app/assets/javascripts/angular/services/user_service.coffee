app.factory 'userService', [ ->

  factory = {}
  factory.user = {}
  factory.user.name = ''
  factory.user.location = ''
  factory.user.solarSystem = {}

  return factory
]
