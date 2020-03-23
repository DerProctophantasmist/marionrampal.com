module.exports = 'quirks'
require('angular').module('quirks', ['config', require('./marked.config'), require('angular-marked'),require('ng-device-detector')])

  .factory('Quirks',['deviceDetector', (deviceDetector) ->
        
      return {
        isMobileLayout: ()->
#          return true;
          switch deviceDetector.device
            when 'iphone','ipad','android','windows-phone' then return true
          return false;
        ,
        androidHeightHack: ()->
          if deviceDetector.os == 'android'
              return (screen.availHeight - 25) + 'px'
          return '100vh' 
      }
    
  ])


