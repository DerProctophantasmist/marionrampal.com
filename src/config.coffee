config = window.config
require('angular').module('config',[])
  .config(['$sceDelegateProvider', '$httpProvider', 'markedProvider', '$compileProvider', ($sceDelegateProvider, $httpProvider, markedProvider,$compileProvider) ->
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
      'http*://*.marionrampal.local/**', 
      'http*://192.168.1.51/**',
      'http*://proctophantasmist.net/**',
      'http*://*.proctophantasmist.net/**'
    ])
    if not $httpProvider.defaults.headers.common?
        $httpProvider.defaults.headers.commom = {}
       
    if PROD? #defined by uglyfy process
      $compileProvider.debugInfoEnabled(false);
      $compileProvider.commentDirectivesEnabled(false);
      $compileProvider.cssClassDirectivesEnabled(false);
      console.log = ()->{}

    markedProvider.setDataPath(config.dataPath);
    
  ])
  .factory('Config', ['$location', ($location) ->
    # local = /(\.local|192\.168\.1\.51)$/.test $location.host()
    # if local != config.local 
    #   msg = 'wrong config file!'
    #   console.log msg      
    hostname = $location.host().split('.').slice( - 2).join('.')

    config.ajaxHost = (uri) ->
      return "https://ajax." + hostname + "/" +uri
      
    return config
    
  ])
  .run(['Config', (config) -> {} ])
module.exports = 'config'