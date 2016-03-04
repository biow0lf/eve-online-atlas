app.filter 'formatText', ->
  (input) ->
    if !input
      return input
    else return input.replace(/(\r\n|\r|\n)/g, '<br/>').replace(/\t/g, '&nbsp;&nbsp;&nbsp;').replace(RegExp(' ', 'g'), '&nbsp;')