!function(e,t){"use strict";var n=e.module("restmod",["ng","platanus.inflector"]);n.provider("restmod",[function(){function t(e){return function(t){t.invoke(e,this,{$builder:this})}}var n=["RMBuilderExt","RMBuilderRelations","RMBuilderComputed"];return{rebase:function(){var r,i,o=arguments.length;for(i=0;o>i;i++)r=arguments[i],(e.isArray(r)||e.isFunction(r))&&(r=t(r)),n.push(r);return this},$get:["RMModelFactory","$log",function(e,t){var r=Array.prototype.slice,i={model:function(i){var o=e(i,n);return arguments.length>1&&(o.mix(r.call(arguments,1)),t.warn("Passing mixins and definitions in the model method will be deprecated in restmod 1.2, use restmod.model().mix() instead.")),o},mixin:function(){return{$isAbstract:!0,$$chain:r.call(arguments,0)}},singleton:function(e){return i.model.apply(this,arguments).single(e)}};return i}]}}]).factory("model",["restmod",function(e){return e.model}]).factory("mixin",["restmod",function(e){return e.mixin}]),n.factory("RMCollectionApi",["RMUtils",function(n){var r=e.extend;return{$isCollection:!0,$initialize:function(){this.$dispatch("after-collection-init")},$decode:function(t,r){n.assert(t&&e.isArray(t),"Collection $decode expected array");for(var i=0,o=t.length;o>i;i++)this.$buildRaw(t[i],r).$reveal();return this.$dispatch("after-feed-many",[t]),this},$encode:function(e){for(var t=[],n=0,r=this.length;r>n;n++)t.push(this[n].$encode(e));return this.$dispatch("before-render-many",[t]),t},$clear:function(){return this.$always(function(){this.length=0})},$fetch:function(e){return this.$action(function(){var t={method:"GET",url:this.$url("fetchMany"),params:this.$params};e&&(t.params=t.params?r(t.params,e):e),this.$dispatch("before-fetch-many",[t]).$send(t,function(e){this.$unwrap(e.data).$dispatch("after-fetch-many",[e])},function(e){this.$dispatch("after-fetch-many-error",[e])})})},$add:function(e,r){return n.assert(e.$type&&e.$type===this.$type,"Collection $add expects record of the same $type"),this.$action(function(){e.$position===t&&(r!==t?this.splice(r,0,e):this.push(e),e.$position=!0,this.$dispatch("after-add",[e]))})},$remove:function(e){return this.$action(function(){var n=this.$indexOf(e);-1!==n&&(this.splice(n,1),e.$position=t,this.$dispatch("after-remove",[e]))})},$indexOf:function(e,t){var r="function"!=typeof e?function(t){return t===e}:e;return n.indexWhere(this,r,t)}}}]),n.factory("RMCommonApi",["$http","RMFastQ","$log","RMUtils",function(n,r,i,o){function a(e,n){var r=e.$dispatcher();return function(i){var o=e.$promise;e.$promise=t;try{e.$last=i;var a=r?e.$decorate(r,n,[e]):n.call(e,e);return a===t?e.$promise:a}finally{e.$promise=o}}}var s=[],u={$url:function(e){if(e){if(e="$"+e+"UrlFor",this.$scope[e])return this.$scope[e](this)}else if(this.$scope.$canonicalUrlFor)return this.$scope.$canonicalUrlFor(this);return this.$scope.$urlFor(this)},$dispatch:function(e,n,r){var i,o,a,u=this.$$dsp;if(r||(r=this),u&&(this.$$dsp=t,u(e,n,r)),this.$$cb&&(i=this.$$cb[e]))for(o=0;a=i[o];o++)a.apply(r,n||s);return this.$scope&&this.$scope.$dispatch?this.$scope.$dispatch(e,n,r):this.$type&&this.$type.$dispatch(e,n,r),this.$$dsp=u,this},$on:function(e,t){var n=(this.$$cb||(this.$$cb={}))[e]||(this.$$cb[e]=[]);return n.push(t),this},$off:function(e,t){if(this.$$cb&&this.$$cb[e]){var n=o.indexWhere(this.$$cb[e],function(e){return e===t});-1!==n&&this.$$cb[e].splice(n,1)}return this},$decorate:function(e,t,n){var r=this.$$dsp;this.$$dsp="function"!=typeof e&&e?function(t,n,i){r&&r.apply(null,arguments);var o=e[t];o&&o.apply(i,n||s)}:e;try{return t.apply(this,n)}finally{this.$$dsp=r}},$dispatcher:function(){return this.$$dsp},$asPromise:function(){var e=this;return this.$promise?this.$promise.then(function(){return e},function(){return r.reject(e)}):r.when(this)},$then:function(e,t){return this.$promise?this.$promise=this.$promise.then(e?a(this,e):e,t?a(this,t):t):this.$promise=r.when(a(this,e)(this)),this},$always:function(e){return this.$then(e,e)},$finally:function(e){return this.$promise=this.$promise["finally"](a(this,e)),this},$send:function(e,t,o){this.$type.getProperty("style")||i.warn("No API style base was selected, see the Api Integration FAQ for more information on this warning");var s=this.$$action;return this.$always(function(){return this.$response=null,this.$status="pending",this.$dispatch("before-request",[e]),n(e).then(a(this,function(){return s&&s.canceled?(this.$status="canceled",this.$dispatch("after-request-cancel",[]),r.reject(this)):(this.$status="ok",this.$response=this.$last,this.$dispatch("after-request",[this.$response]),t&&t.call(this,this.$response),void 0)}),a(this,function(){return s&&s.canceled?(this.$status="canceled",this.$dispatch("after-request-cancel",[])):(this.$status="error",this.$response=this.$last,this.$dispatch("after-request-error",[this.$response]),o&&o.call(this,this.$response)),r.reject(this)}))})},$action:function(e){var t={canceled:!1},n=this.$pending||(this.$pending=[]);return n.push(t),this.$always(function(){var n=this.$$action;try{return t.canceled?r.reject(this):(this.$$action=t,e.call(this))}finally{this.$$action=n}}).$finally(function(){n.splice(n.indexOf(t),1)})},$cancel:function(){return this.$pending&&e.forEach(this.$pending,function(e){e.canceled=!0}),this},$hasPendingActions:function(){var t=0;return this.$pending&&e.forEach(this.$pending,function(e){e.canceled||t++}),t>0}};return u}]),n.factory("RMExtendedApi",["$q","RMPackerCache",function(e,t){return{$decode:function(e,t){return this.$resolved===!1&&this.$clear&&this.$clear(),this.$super(e,t),this.$resolved=!0,this},$unwrap:function(e,n){try{return t.prepare(),e=this.$type.unpack(this,e),this.$decode(e,n)}finally{t.clear()}},$wrap:function(e){var t=this.$encode(e);return t=this.$type.pack(this,t)},$reset:function(){return this.$cancel().$action(function(){this.$resolved=!1})},$resolve:function(e){return this.$action(function(){this.$dispatch("before-resolve",[]),this.$resolved||this.$fetch(e)})},$refresh:function(e){return this.$reset().$fetch(e)}}}]),n.factory("RMListApi",[function(){return{$asList:function(e){var t=this.$type.list(),n=this.$asPromise();return t.$promise=n.then(function(n){t.push.apply(t,e?e(n):n)}),t}}}]),n.factory("RMRecordApi",["RMUtils",function(e){var n=function(t,n,r){this.$scope=t,this.$target=n,this.$partial=e.cleanUrl(r)};return n.prototype={$nestedUrl:function(){return e.joinUrl(this.$scope.$url(),this.$partial)},$urlFor:function(e){return e.$isCollection||this.$target.isNested()?this.$nestedUrl():this.$target.$urlFor(e)},$fetchUrlFor:function(){return this.$nestedUrl()},$createUrlFor:function(){return null}},{$initialize:function(){this.$super(),this.$dispatch("after-init")},$isNew:function(){return this.$pk===t||null===this.$pk},$buildUrl:function(t){return this.$isNew()?null:e.joinUrl(t.$url(),this.$pk+"")},$buildScope:function(e,t){return e.$buildOwnScope?void 0:new n(this,e,t)},$each:function(e,t){for(var n in this)this.hasOwnProperty(n)&&"$"!==n[0]&&e.call(t||this[n],this[n],n);return this},$decode:function(t,n){return e.assert(t&&"object"==typeof t,"Record $decode expected an object"),this.$type.decode(this,t,n||e.READ_MASK),this.$isNew()&&(this.$pk=this.$type.inferKey(t)),this.$dispatch("after-feed",[t]),this},$encode:function(t){var n=this.$type.encode(this,t||e.CREATE_MASK);return this.$dispatch("before-render",[n]),n},$fetch:function(t){return this.$action(function(){var n=this.$url("fetch");e.assert(!!n,"Cant $fetch if resource is not bound");var r={method:"GET",url:n,params:t};this.$dispatch("before-fetch",[r]),this.$send(r,function(e){this.$unwrap(e.data),this.$dispatch("after-fetch",[e])},function(e){this.$dispatch("after-fetch-error",[e])})})},$extend:function(e){return this.$action(function(){for(var t in e)e.hasOwnProperty(t)&&"$"!==t[0]&&(this[t]=e[t])})},$update:function(e){return this.$extend(e).$save()},$save:function(n){return this.$action(function(){var r,i=this.$url("update");i?(r=n?{method:this.$type.getProperty("patchMethod","PATCH"),url:i,data:this.$wrap(function(e){e=e.replace("[]","");for(var t=0,r=n.length;r>t;t++)if(e===n[t]||0===e.indexOf(n[t]+".")||0===n[t].indexOf(e+"."))return!1;return!0})}:{method:"PUT",url:i,data:this.$wrap(e.UPDATE_MASK)},this.$dispatch("before-update",[r,!!n]).$dispatch("before-save",[r]).$send(r,function(e){e.data&&this.$unwrap(e.data),this.$dispatch("after-update",[e,!!n]).$dispatch("after-save",[e])},function(e){this.$dispatch("after-update-error",[e,!!n]).$dispatch("after-save-error",[e])})):(i=this.$url("create")||this.$scope.$url(),e.assert(!!i,"Cant $create if parent scope is not bound"),r={method:"POST",url:i,data:this.$wrap(e.CREATE_MASK)},this.$dispatch("before-save",[r]).$dispatch("before-create",[r]).$send(r,function(e){e.data&&this.$unwrap(e.data),this.$scope.$isCollection&&this.$position===t&&!this.$preventReveal&&this.$scope.$add(this,this.$revealAt),this.$dispatch("after-create",[e]).$dispatch("after-save",[e])},function(e){this.$dispatch("after-create-error",[e]).$dispatch("after-save-error",[e])}))})},$destroy:function(){return this.$action(function(){var e=this.$url("destroy");if(e){var t={method:"DELETE",url:e};this.$dispatch("before-destroy",[t]).$send(t,function(e){this.$scope.$remove&&this.$scope.$remove(this),this.$dispatch("after-destroy",[e])},function(e){this.$dispatch("after-destroy-error",[e])})}else this.$scope.$remove&&this.$scope.$remove(this)})},$moveTo:function(e){return this.$position!==t||(this.$revealAt=e),this},$reveal:function(e){return e===t||e?this.$scope.$add(this,this.$revealAt):this.$preventReveal=!0,this}}}]),n.factory("RMScopeApi",["RMUtils",function(e){return{$urlFor:function(e){var t=this.$type.isNested()?this:this.$type;return"function"==typeof e.$buildUrl?e.$buildUrl(t):t.$url()},$new:function(e,t){return this.$super(e,t)},$build:function(e){return this.$new().$extend(e)},$buildRaw:function(e,t){var n=this.$new(this.$type.inferKey(e));return n.$decode(e,t),n},$find:function(e,t){return this.$new(e).$resolve(t)},$create:function(e){return this.$build(e).$save()},$collection:function(e,t){return this.$super(e,t)},$search:function(e){return this.$collection(e).$fetch()}}}]),n.factory("RMBuilder",["$injector","inflector","$log","RMUtils",function(t,n,r,i){function o(e){var t=[{fun:"attrDefault",sign:["init"]},{fun:"attrMask",sign:["ignore"]},{fun:"attrMask",sign:["mask"]},{fun:"attrMap",sign:["map","force"]},{fun:"attrDecoder",sign:["decode","param","chain"]},{fun:"attrEncoder",sign:["encode","param","chain"]},{fun:"attrVolatile",sign:["volatile"]}];this.dsl=c(e,{describe:function(e){return a(e,function(e,t){switch(t.charAt(0)){case"@":r.warn("Usage of @ in description objects will be removed in 1.2, use a $extend block instead"),this.define("Scope."+t.substring(1),e);break;case"~":t=n.parameterize(t.substring(1)),r.warn("Usage of ~ in description objects will be removed in 1.2, use a $hooks block instead"),this.on(t,e);break;default:if("$config"===t)for(var i in e)e.hasOwnProperty(i)&&this.setProperty(i,e[i]);else if("$extend"===t)for(var i in e)e.hasOwnProperty(i)&&this.define(i,e[i]);else if("$hooks"===t)for(var i in e)e.hasOwnProperty(i)&&this.on(i,e[i]);else f.test(t)?(r.warn("Usage of ~ in description objects will be removed in 1.2, use a $config block instead"),t=n.camelize(t.toLowerCase()),this.setProperty(t,e)):s(e)?this.attribute(t,e):l(e)?this.define(t,e):this.attrDefault(t,e)}},this),this},extend:function(e,n,r){return"string"==typeof e?(this[e]=i.override(this[name],n),r&&t.push({fun:e,sign:r})):i.extendOverriden(this,e),this},attribute:function(e,n){for(var r,i=0;r=t[i++];)if(n.hasOwnProperty(r.sign[0])){for(var o=[e],a=0;a<r.sign.length;a++)o.push(n[r.sign[a]]);o.push(n),this[r.fun].apply(this,o)}return this}})}var a=e.forEach,s=e.isObject,u=e.isArray,l=e.isFunction,c=e.extend,f=/^[A-Z]+[A-Z_0-9]*$/;return o.prototype={chain:function(e){for(var t=0,n=e.length;n>t;t++)this.mixin(e[t])},mixin:function(e){e.$$chain?this.chain(e.$$chain):"string"==typeof e?this.mixin(t.get(e)):u(e)?this.chain(e):l(e)?e.call(this.dsl,t):this.dsl.describe(e)}},o}]),n.factory("RMBuilderComputed",["restmod",function(e){var t={attrAsComputed:function(e,t){return this.attrComputed(e,t),this}};return e.mixin(function(){this.extend("attrAsComputed",t.attrAsComputed,["computed"])})}]),n.factory("RMBuilderExt",["$injector","$parse","inflector","$log","restmod",function(t,n,r,i,o){var a=e.bind,s=e.isFunction,u={setUrlPrefix:function(e){return this.setProperty("urlPrefix",e)},setPrimaryKey:function(e){return this.setProperty("primaryKey",e)},attrSerializer:function(e,n,i){return"string"==typeof n&&(n=t.get(r.camelize(n,!0)+"Serializer")),s(n)&&(n=n(i)),n.decode&&this.attrDecoder(e,a(n,n.decode)),n.encode&&this.attrEncoder(e,a(n,n.encode)),this},attrExpression:function(e,t){var r=n(t);return this.on("after-feed",function(){this[e]=r(this)})}};return o.mixin(function(){this.extend("setUrlPrefix",u.setUrlPrefix).extend("setPrimaryKey",u.setPrimaryKey).extend("attrSerializer",u.attrSerializer,["serialize"])})}]),n.factory("RMBuilderRelations",["$injector","inflector","$log","RMUtils","restmod","RMPackerCache",function(e,n,r,i,o,a){function s(e,t){return function(){var n=this.$owner;this.$owner=t;try{return e.apply(this,arguments)}finally{this.$owner=n}}}function u(e,t,n){for(var r in t)t.hasOwnProperty(r)&&e.$on(r,s(t[r],n))}var l={attrAsCollection:function(t,n,o,a,s,l,c){var f,d;return this.attrDefault(t,function(){if("string"==typeof n&&(n=e.get(n),f=n.getProperty("hasMany",{}),d=f.hooks,s)){var i=n.$$getDescription(s);i&&"belongs_to"===i.relation||(r.warn("Must define an inverse belongsTo relation for inverseOf to work"),s=!1)}var a,p=this.$buildScope(n,o||n.encodeUrlName(t));if(a=n.$collection(l||null,p),d&&u(a,d,this),c&&u(a,c,this),a.$dispatch("after-has-many-init"),s){var h=this;a.$on("after-add",function(e){e[s]=h})}return a}),(a||o)&&this.attrMap(t,a||o),this.attrDecoder(t,function(e){this[t].$reset().$decode(e||[])}).attrMask(t,i.WRITE_MASK).attrMeta(t,{relation:"has_many"}),this},attrAsResource:function(t,n,o,a,s,l){var c,f;return this.attrDefault(t,function(){if("string"==typeof n&&(n=e.get(n),c=n.getProperty("hasOne",{}),f=c.hooks,s)){var i=n.$$getDescription(s);i&&"belongs_to"===i.relation||(r.warn("Must define an inverse belongsTo relation for inverseOf to work"),s=!1)}var a,d=this.$buildScope(n,o||n.encodeUrlName(t));return a=n.$new(null,d),f&&u(a,f,this),l&&u(a,l,this),a.$dispatch("after-has-one-init"),s&&(a[s]=this),a}),(a||o)&&this.attrMap(t,a||o),this.attrDecoder(t,function(e){this[t].$decode(e||{})}).attrMask(t,i.WRITE_MASK).attrMeta(t,{relation:"has_one"}),this},attrAsReference:function(n,r,o,s){function u(){"string"==typeof r&&(r=e.get(r))}return this.attrDefault(n,null).attrMask(n,i.WRITE_MASK).attrMeta(n,{relation:"belongs_to"}),this.attrDecoder(n,function(e){return null===e?null:(u(),void(this[n]&&this[n].$pk===r.inferKey(e)?this[n].$decode(e):this[n]=r.$buildRaw(e)))}),o!==!1&&this.attrMap(n+"Id",o||"*",!0).attrDecoder(n+"Id",function(e){e!==t&&(this[n]&&this[n].$pk===e||(null!==e&&e!==!1?(u(),this[n]=a.resolve(r.$new(e)),s&&this[n].$fetch()):this[n]=null))}).attrEncoder(n+"Id",function(){return this[n]?this[n].$pk:null}),this},attrAsReferenceToMany:function(t,r,o){function s(){"string"==typeof r&&(r=e.get(r))}function u(e,t){s(),t.length=0;for(var n=0,i=e.length;i>n;n++)"object"==typeof e[n]?t.push(r.$buildRaw(e[n])):t.push(a.resolve(r.$new(e[n])))}if(this.attrDefault(t,function(){return[]}).attrMask(t,i.WRITE_MASK).attrMeta(t,{relation:"belongs_to_many"}),this.attrDecoder(t,function(e){e&&u(e,this[t])}),o!==!1){var l=n.singularize(t)+"Ids";this.attrMap(l,o||"*",!0).attrDecoder(l,function(e){e&&u(e,this[t])}).attrEncoder(l,function(){for(var e=[],n=this[t],r=0,i=n.length;i>r;r++)e.push(n[r].$pk);return e})}return this}};return o.mixin(function(){this.extend("attrAsCollection",l.attrAsCollection,["hasMany","path","source","inverseOf","params","hooks"]).extend("attrAsResource",l.attrAsResource,["hasOne","path","source","inverseOf","hooks"]).extend("attrAsReference",l.attrAsReference,["belongsTo","key","prefetch"]).extend("attrAsReferenceToMany",l.attrAsReferenceToMany,["belongsToMany","keys"])})}]),n.factory("RMModelFactory",["$injector","$log","inflector","RMUtils","RMScopeApi","RMCommonApi","RMRecordApi","RMListApi","RMCollectionApi","RMExtendedApi","RMSerializer","RMBuilder",function(n,r,i,o,a,s,u,l,c,f,d,p){var h=/(.*?)([^\/]+)\/?$/,g=o.extendOverriden;return function(n,m){function v(e,t){this.$scope=e||v,this.$pk=t,this.$initialize()}function $(e,t){var n=new k;return n.$scope=t||v,n.$params=e,n.$initialize(),n}function y(e,t,n){var r=P[e];o.assert(!!r,"Invalid api name $1",e),t?r[t]=o.override(r[t],n):o.extendOverriden(r,n)}n=o.cleanUrl(n);var b,w={primaryKey:"id",urlPrefix:null},x=new d(v),_=[],A=[],E={},S={};n&&(w.name=i.singularize(n.replace(h,"$2")));var k=o.buildArrayType(),C=o.buildArrayType(),R=function(e){this.$isCollection=e,this.$initialize()};g(v,{$$getDescription:function(e){return E[e]},$$chain:[],$type:v,$new:function(e,t){return new v(t||v,e)},$collection:$,$url:function(){return w.urlPrefix?o.joinUrl(w.urlPrefix,n):n},$dispatch:function(e,t,n){var r,i,o=S[e];if(o)for(r=0;i=o[r];r++)i.apply(n||this,t||[]);return this},inferKey:function(e){return e&&"undefined"!=typeof e[w.primaryKey]?e[w.primaryKey]:null},getProperty:function(e,n){var r=w[e];return r!==t?r:n},isNested:function(){return!n},single:function(e){return new v({$urlFor:function(){return w.urlPrefix?o.joinUrl(w.urlPrefix,e):e}},"")},dummy:function(e){return new R(e)},list:function(e){var t=new C;return e&&t.push.apply(t,e),t},identity:function(e){if(!e)return w.name;if(e){if(w.plural)return w.plural;if(w.name)return i.pluralize(w.name)}return null},mix:function(){return b.chain(arguments),this.$$chain.push.apply(this.$$chain,arguments),this},unpack:function(e,t){return t},pack:function(e,t){return t},decode:x.decode,encode:x.encode,decodeName:null,encodeName:null,encodeUrlName:function(e){return r.warn("Default paremeterization of urls will be disabled in 1.2, override Model.encodeUrlName with inflector.parameterize in your base model to keep the same behaviour."),i.parameterize(e)}},a),g(v.prototype,{$type:v,$initialize:function(){var e,t,n=this;for(t=0;e=_[t];t++)this[e[0]]="function"==typeof e[1]?e[1].apply(this):e[1];for(t=0;e=A[t];t++)Object.defineProperty(n,e[0],{enumerable:!0,get:e[1],set:function(){}})}},s,u,f),g(k.prototype,{$type:v,$new:function(e,t){return v.$new(e,t||this)},$collection:function(t,n){return t=this.$params?e.extend({},this.$params,t):t,$(t,n||this.$scope)}},l,a,s,c,f),g(C.prototype,{$type:v},l,s),g(R.prototype,{$type:v,$initialize:function(){}},s);var P={Model:v,Record:v.prototype,Collection:k.prototype,List:C.prototype,Dummy:R.prototype};return b=new p(e.extend(x.dsl(),{setProperty:function(e,t){return w[e]=t,this},attrDefault:function(e,t){return _.push([e,t]),this},attrComputed:function(e,t){return A.push([e,t]),this.attrMask(e,!0),this},attrMeta:function(e,t){return E[e]=g(E[e]||{},t),this},define:function(e,t){var n=!1,r="Record";switch("object"==typeof t&&t?r=e:(n=e.split("."),1===n.length?n=n[0]:(r=n[0],n=n[1])),r){case"List":y("Collection",n,t),y("List",n,t);break;case"Scope":y("Model",n,t),y("Collection",n,t);break;case"Resource":y("Record",n,t),y("Collection",n,t),y("List",n,t),y("Dummy",n,t);break;default:y(r,n,t)}return this},on:function(e,t){return(S[e]||(S[e]=[])).push(t),this}})),b.chain(m),v}}]),n.factory("RMFastQ",[function(){function t(e,o){return e&&r(e.then)?n(e):{simple:!0,then:function(n,r){return t(o?r(e):n(e))},"catch":i,"finally":function(i){var a=i();return a&&r(e.then)?n(e.then(function(){return o?t(e,!0):e},function(){return o?t(e,!0):e})):this}}}function n(e){if(e.simple)return e;var r;return e.then(function(e){r=t(e)},function(e){r=t(e,!0)}),{then:function(t,i){return r?r.then(t,i):n(e.then(t,i))},"catch":i,"finally":function(t){return r?r["finally"](t):n(e["finally"](t))}}}var r=e.isFunction,i=function(e){return this.then(null,e)};return{reject:function(e){return t(e,!0)},when:function(e){return t(e,!1)},wrap:n}}]),n.factory("RMPackerCache",[function(){var e;return{feed:function(t,n){e[t]=n},resolve:function(t){if(e){var n=t.$type,r=e[n.identity(!0)];if(r&&t.$pk)for(var i=0,o=r.length;o>i;i++)if(t.$pk===n.inferKey(r[i])){t.$decode(r[i]);break}}return t},prepare:function(){e={}},clear:function(){e=null}}}]),n.factory("RMSerializer",["$injector","inflector","$filter","RMUtils",function(n,r,i,o){function a(e,n){if(null===e&&n.length>1)return t;for(var r,i=0;e&&(r=n[i]);i++)e=e[r];return e}function s(e,t,n){for(var r=0,i=t.length-1;i>r;r++){var o=t[r];e=e[o]||(e[o]={})}e[t[t.length-1]]=n}return function(n){function r(e,t,n){if("function"==typeof t)return t(e);var r=p[e];return"function"==typeof r&&(r=r.call(n)),r&&(r===!0||-1!==r.indexOf(t))}function u(e,i,o,s,u){var c,f,d,p,h,g,$,y,b=o?o+".":"";if(h=v[o])for($=0,y=h.length;y>$;$++)d=b+h[$].path,r(d,s,u)||(p=h[$].map?a(e,h[$].map):e[n.encodeName?n.encodeName(h[$].path):h[$].path],(h[$].forced||p!==t)&&(p=l(p,d,s,u),p!==t&&(i[h[$].path]=p)));for(c in e)if(e.hasOwnProperty(c)){if(f=n.decodeName?n.decodeName(c):c,"$"===f[0])continue;if(h){for(g=!1,$=0,y=h.length;y>$&&!(g=h[$].mapPath===c);$++);if(g)continue}if(d=b+f,m[d]||r(d,s,u))continue;p=l(e[c],d,s,u),p!==t&&(i[f]=p)}}function l(e,t,n,r){var i=h[t],o=e;if(i)o=i.call(r,e,n);else if("object"==typeof e)if(d(e)){o=[];for(var a=0,s=e.length;s>a;a++)o.push(l(e[a],t+"[]",n,r))}else e&&(o={},u(e,o,t,n,r));return o}function c(e,i,o,a,u){var l,c,d,p,h,g=o?o+".":"";for(l in e)if(e.hasOwnProperty(l)&&"$"!==l[0]){if(c=g+l,m[c]||r(c,a,u))continue;p=f(e[l],c,a,u),p!==t&&(d=n.encodeName?n.encodeName(l):l,i[d]=p),$[c]&&delete e[l]}if(h=v[o])for(var y=0,b=h.length;b>y;y++)c=g+h[y].path,r(c,a,u)||(p=e[h[y].path],(h[y].forced||p!==t)&&(p=f(p,c,a,u),p!==t&&(h[y].map?s(i,h[y].map,p):i[n.encodeName?n.encodeName(h[y].path):h[y].path]=p)))}function f(e,t,n,r){var i=g[t],o=e;if(i)o=i.call(r,e,n);else if(null!==e&&"object"==typeof e&&"function"!=typeof e.toJSON)if(d(e)){o=[];for(var a=0,s=e.length;s>a;a++)o.push(f(e[a],t+"[]",n,r))}else e&&(o={},c(e,o,t,n,r));return o}var d=e.isArray,p={},h={},g={},m={},v={},$={};return{decode:function(e,t,n){u(t,e,"",n,e)},encode:function(e,t){var n={};return c(e,n,"",t,e),n},dsl:function(){return{attrMap:function(e,t,n){var r=e.lastIndexOf("."),i=-1!==r?e.substr(0,r):"",o=-1!==r?e.substr(r+1):e;m[e]=!0;var a=v[i]||(v[i]=[]);return a.push({path:o,map:"*"===t?null:t.split("."),mapPath:t,forced:n}),this},attrMask:function(e,t){return t?p[e]=t:delete p[e],this},attrDecoder:function(e,t,n,r){if("string"==typeof t){var a=i(t);t=function(e){return a(e,n)}}return h[e]=r?o.chain(h[e],t):t,this},attrEncoder:function(e,t,n,r){if("string"==typeof t){var a=i(t);t=function(e){return a(e,n)}}return g[e]=r?o.chain(g[e],t):t,this},attrVolatile:function(e,n){return $[e]=n===t?!0:n,this}}}}}}]),n.factory("DefaultPacker",["restmod","inflector","RMPackerCache",function(t,n,r){function i(e,t,n){for(var r=0,i=t.length;i>r;r++)n(t[r],e[t[r]])}function o(e,t,n){for(var r in e)e.hasOwnProperty(r)&&-1===t.indexOf(r)&&n(r,e[r])}function a(t,n,r,a,s){if("."===r||r===!0){var u=[n];a&&u.push.apply(u,e.isArray(a)?a:[a]),o(t,u,s)}else"string"==typeof r?o(t[r],[],s):i(t,r,s)}return t.mixin(function(){this.define("Model.unpack",function(e,t){var n=null,i=this.getProperty("jsonLinks","included"),o=this.getProperty("jsonMeta","meta");return n=e.$isCollection?this.getProperty("jsonRootMany")||this.getProperty("jsonRoot")||this.identity(!0):this.getProperty("jsonRootSingle")||this.getProperty("jsonRoot")||this.identity(),o&&(e.$metadata={},a(t,n,o,i,function(t,n){e.$metadata[t]=n})),i&&a(t,n,i,o,function(e,t){r.feed(e,t)}),t[n]})})}]),n.factory("RMUtils",["$log",function(e){var t=[],n=function(){var e=function(){};return Object.setPrototypeOf?function(e,t){Object.setPrototypeOf(e,t)}:(new e).__proto__===e.prototype?function(e,t){e.__proto__=t}:void 0}(),r={CREATE_MASK:"C",UPDATE_MASK:"U",READ_MASK:"R",WRITE_MASK:"CU",FULL_MASK:"CRU",format:function(e,t){for(var n=0;t&&n<t.length;n++)e=e.replace("$"+(n+1),t[n]);return e},assert:function(t,n){if(!t){var i=Array.prototype.slice.call(arguments,2);throw n=r.format(n,i),e.error(n),new Error(n)}},joinUrl:function(e,t){return e&&t?(e+"").replace(/\/$/,"")+"/"+(t+"").replace(/^\//,""):null},cleanUrl:function(e){return e?e.replace(/\/$/,""):e},chain:function(e,t){return e?function(n){return t.call(this,e.call(this,n))}:t},override:function(e,t){return e&&"function"==typeof t?function(){var n=this.$super;try{return this.$super=e,t.apply(this,arguments)}finally{this.$super=n}}:t},indexWhere:function(e,t,n){for(var r=n||0,i=e.length;i>r;r++)if(t(e[r]))return r;return-1},extendOverriden:function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var i in n)n.hasOwnProperty(i)&&(e[i]=e[i]&&"function"==typeof e[i]?r.override(e[i],n[i]):n[i])}return e},buildArrayType:function(e){var r;if(n&&!e){var i=function(){var e=[];return e.push.apply(e,arguments),n(e,i.prototype),e};i.prototype=[],i.prototype.last=function(){return this[this.length-1]},r=i}else{var o=document.createElement("iframe");o.style.display="none",o.height=0,o.width=0,o.border=0,document.body.appendChild(o),window.frames[window.frames.length-1].document.write("<script>parent.RestmodArray = Array;</script>"),r=window.RestmodArray,delete window.RestmodArray;for(var a in Array.prototype)"function"!=typeof Array.prototype[a]||r.prototype[a]||(r.prototype[a]=Array.prototype[a]);document.body.removeChild(o),t.push(o)}return r}};return r}])}(angular);