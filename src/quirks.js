// Generated by CoffeeScript 2.5.1
(function() {
  module.exports = 'quirks';

  require('angular').module('quirks', ['config', require('./marked.config'), require('angular-marked'), require('ng-device-detector')]).factory('Quirks', [
    'deviceDetector',
    function(deviceDetector) {
      return {
        isMobileLayout: function() {
          //          return true;
          switch (deviceDetector.device) {
            case 'iphone':
            case 'ipad':
            case 'android':
            case 'windows-phone':
              return true;
          }
          return false;
        },
        androidHeightHack: function() {
          if (deviceDetector.os === 'android') {
            return (screen.availHeight - 25) + 'px';
          }
          return '100vh';
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=quirks.js.map
