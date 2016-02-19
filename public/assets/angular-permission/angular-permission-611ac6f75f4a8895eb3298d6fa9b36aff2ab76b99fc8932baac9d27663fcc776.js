!function(){"use strict";var e=angular.module("permission",["ui.router"]);e.config(["$stateProvider",function(e){e.decorator("parent",function(e,t){return e.self.getState=function(){return e},t(e)})}]),e.run(["$rootScope","$state","$q","Authorization","PermissionMap",function(e,t,n,r,i){e.$on("$stateChangeStart",function(n,o,a,s,u,c){function l(e){return angular.isDefined(e.data)&&angular.isDefined(e.data.permissions)}function f(e){o=angular.extend({$$isAuthorizationFinished:e},o)}function p(){return v()||m()}function h(e){var n=new i({redirectTo:e.redirectTo}),r=t.get(o.name).getState().path.slice().reverse();return angular.forEach(r,function(e){l(e)&&n.extendPermissionMap(new i(e.data.permissions))}),n}function d(t){r.authorize(t,a).then(function(){e.$broadcast("$stateChangePermissionAccepted",o,a,c),g(o.name)})["catch"](function(n){e.$broadcast("$stateChangePermissionDenied",o,a,c),t.redirectToState(n)})}function g(n){t.go(n,a,angular.extend({},c,{notify:!1})).then(function(){e.$broadcast("$stateChangeSuccess",o,a,s,u,c)})}function m(){return e.$broadcast("$stateChangeStart",o,a,s,u,c).defaultPrevented}function v(){return e.$broadcast("$stateChangePermissionStart",o,a,c).defaultPrevented}if(!o.$$isAuthorizationFinished&&l(o)&&(n.preventDefault(),f(!0),!p())){var $=h(o.data.permissions);d($)}})}])}(),function(){"use strict";angular.module("permission").factory("PermissionMap",["$q","$state",function(e,t){function n(e,t,n,r){this.only=a(e.only,t,n,r),this.except=a(e.except,t,n,r),this.redirectTo=e.redirectTo}function r(t,n){e.when(t.call(null,n)).then(function(e){if(!angular.isString(e))throw new TypeError('When used "redirectTo" as function, returned value must be string with state name');o(e)})}function i(e,t){if(!angular.isDefined(e["default"]))throw new ReferenceError('When used "redirectTo" as object, property "default" must be defined');var n=e[t];angular.isDefined(n)||(n=e["default"]),angular.isFunction(n)&&r(n,t),angular.isString(n)&&o(n)}function o(e,n,r){t.go(e,n,r)}function a(e,t,n,r){return angular.isString(e)?[e]:angular.isArray(e)?e:angular.isFunction(e)?e.call(null,t,n,r):[]}return n.prototype.extendPermissionMap=function(e){this.only=this.only.concat(e.only),this.except=this.except.concat(e.except)},n.prototype.redirectToState=function(e){angular.isFunction(this.redirectTo)&&r(this.redirectTo,e),angular.isObject(this.redirectTo)&&i(this.redirectTo,e),angular.isString(this.redirectTo)&&o(this.redirectTo,this.toParams,this.options)},n}])}(),function(){"use strict";angular.module("permission").factory("Permission",["$q",function(e){function t(e,t){r(e,t),this.permissionName=e,this.validationFunction=t}function n(t,n){var r=e.defer();return t?r.resolve(n):r.reject(n),r.promise}function r(e,t){if(!angular.isString(e))throw new TypeError('Parameter "permissionName" name must be String');if(!angular.isFunction(t))throw new TypeError('Parameter "validationFunction" must be Function')}return t.prototype.validatePermission=function(e){var t=this.validationFunction.call(null,e,this.permissionName);return angular.isFunction(t.then)||(t=n(t,this.permissionName)),t},t}])}(),function(){"use strict";angular.module("permission").factory("Role",["$q","PermissionStore",function(e,t){function n(e,n,r){i(e,n,r),this.roleName=e,this.permissionNames=n||[],this.validationFunction=r,r&&t.defineManyPermissions(n,r)}function r(t,n){var r=e.defer();return t?r.resolve(n):r.reject(n),r.promise}function i(e,t,n){if(!angular.isString(e))throw new TypeError('Parameter "roleName" name must be String');if(!angular.isArray(t))throw new TypeError('Parameter "permissionNames" must be Array');if(!t.length&&!angular.isFunction(n))throw new TypeError('Parameter "validationFunction" must be provided for empty "permissionNames" array')}return n.prototype.validateRole=function(n){if(this.permissionNames.length){var i=this.permissionNames.map(function(i){if(t.hasPermissionDefinition(i)){var o=t.getPermissionDefinition(i),a=o.validationFunction.call(null,n,o.permissionName);return angular.isFunction(a.then)||(a=r(a)),a}return e.reject(null)});return e.all(i)}var o=this.validationFunction.call(null,n,this.roleName);return angular.isFunction(o.then)||(o=r(o,this.roleName)),e.resolve(o)},n}])}(),function(){"use strict";angular.module("permission").service("PermissionStore",["Permission",function(e){function t(t,n){u[t]=new e(t,n)}function n(e,n){if(!angular.isArray(e))throw new TypeError('Parameter "permissionNames" name must be Array');angular.forEach(e,function(e){t(e,n)})}function r(e){delete u[e]}function i(e){return angular.isDefined(u[e])}function o(e){return u[e]}function a(){return u}function s(){u={}}var u={};this.definePermission=t,this.defineManyPermissions=n,this.removePermissionDefinition=r,this.hasPermissionDefinition=i,this.getPermissionDefinition=o,this.getStore=a,this.clearStore=s}])}(),function(){"use strict";angular.module("permission").service("RoleStore",["Role",function(e){function t(t,n,r){s[t]=new e(t,n,r)}function n(e){delete s[e]}function r(e){return angular.isDefined(s[e])}function i(e){return s[e]}function o(){return s}function a(){s={}}var s={};this.defineRole=t,this.getRoleDefinition=i,this.hasRoleDefinition=r,this.removeRoleDefinition=n,this.getStore=o,this.clearStore=a}])}(),function(){"use strict";angular.module("permission").directive("permission",["$log","Authorization","PermissionMap",function(e,t,n){return{restrict:"A",bindToController:{only:"=",except:"="},controllerAs:"permission",controller:["$scope","$element",function(r,i){var o=this;r.$watchGroup(["permission.only","permission.except"],function(){try{t.authorize(new n({only:o.only,except:o.except}),null).then(function(){i.removeClass("ng-hide")})["catch"](function(){i.addClass("ng-hide")})}catch(r){i.addClass("ng-hide"),e.error(r.message)}})}]}}])}(),function(){"use strict";angular.module("permission").service("Authorization",["$q","PermissionMap","PermissionStore","RoleStore",function(e,t,n,r){function i(e,t){return o(e,t)}function o(t,n){var r=e.defer(),i=s(t.except,n);return a(i).then(function(e){r.reject(e)})["catch"](function(){t.only.length||r.resolve(null);var e=s(t.only,n);a(e).then(function(e){r.resolve(e)})["catch"](function(e){r.reject(e)})}),r.promise}function a(t){var n=e.defer(),r=0,i=angular.isArray(t)?[]:{};return angular.forEach(t,function(t,o){r++,e.when(t).then(function(e){i.hasOwnProperty(o)||n.resolve(e)})["catch"](function(e){i.hasOwnProperty(o)||(i[o]=e,--r||n.reject(e))})}),0===r&&n.reject(i),n.promise}function s(t,i){return t.map(function(t){return r.hasRoleDefinition(t)?u(t,i):n.hasPermissionDefinition(t)?c(t,i):t?e.reject(t):void 0})}function u(e,t){var n=r.getRoleDefinition(e);return n.validateRole(t)}function c(e,t){var r=n.getPermissionDefinition(e);return r.validatePermission(t)}this.authorize=i}])}();