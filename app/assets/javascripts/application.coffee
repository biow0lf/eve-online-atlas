# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require hacktimer
#= require hacktimerworker
#= require lodash
#= require angular
#= require angular-sanitize
#= require angular-ui-router
#= require ui-router-extras
#= require moment
#= require moment-timezone
#= require angular-aria
#= require angular-animate
#= require angular-material
#= require angular-messages
#= require angular-rails-templates
#= require angular-permission
#= require angular-moment
#= require ng-rails-csrf
#= require angular-material-data-table
#= require ng-file-upload
#= require d3
#= require c3
#= require c3-angular
#= require cytoscape
#= require main
#= require_tree .
#= require_tree ../templates

String::toTitleCase = ->
  smallWords = /^(a|an|and|as|at|but|by|en|for|if|in|nor|of|on|or|per|the|to|vs?\.?|via)$/i
  @replace /[A-Za-z0-9\u00C0-\u00FF]+[^\s-]*/g, (match, index, title) ->
    return match.toLowerCase()  if index > 0 and index + match.length isnt title.length and match.search(smallWords) > -1 and title.charAt(index - 2) isnt ":" and (title.charAt(index + match.length) isnt "-" or title.charAt(index - 1) is "-") and title.charAt(index - 1).search(/[^\s-]/) < 0
    return match  if match.substr(1).search(/[A-Z]|\../) > -1
    match.charAt(0).toUpperCase() + match.substr(1)