(function(){app.controller("chatTrackerCtrl",["$scope","$http",function(e,t){return function(e){return function(){var t,i,n,o,r;e.version="0.0.0",e.file=new File([""],"filename"),e.lastMod=e.file.lastModifiedDate,t=function(){},r=function(){return e.file.lastModifiedDate.getTime()!==e.lastMod.getTime()?(e.lastMod=e.file.lastModifiedDate,n(e.file)):void 0},o=function(t){e.file=t,setInterval(r,250)},n=function(e){var t;return 0!==e.size?(t=new FileReader,t.onload=function(e){var t;return t=e.target.result,console.log(t)},t.readAsText(e)):void 0},i=function(){return e.version="0.0.1"},i(),e.do_post=t,e.setFile=o}}(this)()}])}).call(this);