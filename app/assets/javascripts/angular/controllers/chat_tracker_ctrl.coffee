app.controller 'chatTrackerCtrl', ['$scope', '$http',
  ($scope, $http) -> do =>
    @version = '0.0.0'
    @file = new File([""], "filename")
    @lastMod = @file.lastModifiedDate

    do_post = =>
      return

    tick = =>
      if @file.lastModifiedDate.getTime() != @lastMod.getTime()
        @lastMod = @file.lastModifiedDate
        readFile(@file)

    setFile = (file) =>
      @file = file
      setInterval(tick, 250)
      return

    readFile = (file) =>
      if file.size != 0
        fileReader = new FileReader
        fileReader.onload = (e) ->
          text = e.target.result;
          console.log text
  #        lines = text.split(/[\r\n]+/g); # tolerate both Windows and Unix linebreaks
  #        for line in lines
  #          console.log line

        fileReader.readAsText file

    init = =>
      @version = '0.0.1'

    init()

    #-- Public Functions

    @do_post = do_post
    @setFile = setFile

    return
]
