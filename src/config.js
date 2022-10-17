// Generated by CoffeeScript 2.6.1
(function() {
  var config;

  config = window.config;

  require('angular').module('config', [require('angular-marked'), require('./sections.ng')]).config([
    '$sceDelegateProvider',
    '$httpProvider',
    'markedProvider',
    '$compileProvider',
    function($sceDelegateProvider,
    $httpProvider,
    markedProvider,
    $compileProvider) {
      $sceDelegateProvider.resourceUrlWhitelist([
        // Allow same origin resource loads.
        'self',
        // Allow loading from our assets domain.  Notice the difference between * and **.
        'http*://*.soundcloud.com/**',
        'http*://soundcloud.com/**',
        'http*://vimeo.com/**',
        'http*://*.vimeo.com/**',
        'http*://*.akamaihd.net/**',
        'http*://akamaihd.net/**',
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
      ]);
      if ($httpProvider.defaults.headers.common == null) {
        $httpProvider.defaults.headers.commom = {};
      }
      if (typeof PROD !== "undefined" && PROD !== null) {
        $compileProvider.debugInfoEnabled(false);
        $compileProvider.commentDirectivesEnabled(false);
        $compileProvider.cssClassDirectivesEnabled(false);
        console.log = function() {
          return {};
        }; //defined by uglyfy process
      }
      return markedProvider.setDataPath(config.dataPath);
    }
  ]).factory('Config', [
    '$location',
    'Sections',
    function($location,
    Sections) {
      var hostname;
      // local = /(\.local|192\.168\.1\.51)$/.test $location.host()
      // if local != config.local 
      //   msg = 'wrong config file!'
      //   console.log msg      
      hostname = $location.host().split('.').slice(-2).join('.');
      config.ajaxHost = function(uri) {
        return "https://ajax." + hostname + "/" + uri;
      };
      return config;
    }
  ]).run([
    'Config',
    function(config) {
      return {};
    }
  ]);

  module.exports = 'config';

}).call(this);

//# sourceMappingURL=config.js.map
