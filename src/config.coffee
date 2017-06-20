config = require './config.data.js'
require('angular').module('config',[])
  .config(['$sceDelegateProvider', '$httpProvider', ($sceDelegateProvider, $httpProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist([
      # Allow same origin resource loads.
      'self',
      # Allow loading from our assets domain.  Notice the difference between * and **.
      'http*://*.soundcloud.com/**',
      'http*://soundcloud.com/**',
      'http*://vimeo.com/**',
      'http*://*.vimeo.com/**',
      'http*://*.youtube.com/**',
      'http*://youtube.com/**',
      'http*://*.youtu.be/**',
      'http*://youtu.be/**',      
      'http*://google.com/**',      
      'http*://*.google.com/**',
      'http*://*.marionrampal.com/**',
    ])
    
  ])
  .factory('Config', ['$location', ($location) ->
    local = /(\.local|192\.168\.1\.51)$/.test $location.host()
    if local != config.local 
      msg = 'wrong config file!'
      console.log msg      
    
    config.ajaxHost = (uri) ->
      if local
        return "http://ajax.marionrampal.local" + "/" +uri
      return "http://ajax.marionrampal.com" + "/" + uri
    return config
    
  ])
  .run(['Config', (config) ->
  ])
module.exports = 'config'