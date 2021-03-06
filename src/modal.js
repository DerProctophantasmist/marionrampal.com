// Generated by CoffeeScript 2.5.1
(function() {
  var baseParams, makeMenu;

  module.exports = 'menu';

  baseParams = {
    windowClass: 'main-menu',
    backdrop: true,
    controller: [
      '$scope',
      '$uibModalInstance',
      'Sections',
      'State',
      function($scope,
      $uibModalInstance,
      Sections,
      State) {
        //on opening the menu we navigate back to the home state, so that all "pages" are available.
        State.home();
        this.title = 'Menu';
        this.ok = function(e) {
          $uibModalInstance.close();
          if (e) {
            return e.stopPropagation();
          }
        };
        this.cancel = function(e) {
          $uibModalInstance.dismiss();
          if (e) {
            return e.stopPropagation();
          }
        };
        this.sections = Sections.data;
        return this;
      }
    ],
    controllerAs: 'MenuCtrl'
  };

  makeMenu = function() {
    return function($aside) {
      var menu;
      menu = null;
      return {
        open: function(params) { //params is an object must include placement and template or templateUrl 
          if (menu !== null) {
            console.log("trying to open main menu while it already is");
            return menu;
          }
          menu = $aside.open({...baseParams, ...params});
          menu.result.then((function() {
            console.log('Closed menu');
            return menu = null;
          }), (function() {
            console.log('Dismissed menu');
            return menu = null;
          }));
          return menu.result;
        },
        isOpen: function() {
          return menu !== null;
        },
        close: function() {
          if (menu === null) {
            console.log("trying to close main menu while not open");
            return;
          }
          return menu.close();
        },
        dismiss: function() {
          if (menu === null) {
            console.log("trying to dismiss main menu while not open");
            return;
          }
          return menu.dismiss();
        }
      };
    };
  };

  require('angular').module('menu', [require('angular-aside'), require('./states')]).factory('Menu', ['$aside', makeMenu()]).directive("mainMenu", [
    'Menu',
    function(Menu) {
      return {
        restrict: 'A',
        scope: false,
        replace: false,
        link: function(scope,
    elt,
    attrs) {
          return elt.on('click',
    function() {
            return Menu.open({
              placement: 'right',
              templateUrl: 'templates/menu.html'
            }).then((function() {
              return console.log(' Closed menu 2');
            }),
    function() {
              return console.log(' Dismissed menu 2');
            });
          });
        }
      };
    }
  ]).factory('LeftAside', ['$aside', makeMenu()]).directive("leftAside", [
    'LeftAside',
    function(Menu) {
      return {
        restrict: 'A',
        scope: false,
        replace: false,
        link: function(scope,
    elt,
    attrs) {
          return elt.on('click',
    function() {
            return Menu.open({
              placement: 'left',
              template: '<div class="sidebar menu" style="height:100%;width:100%" marked compile=true filename="\'' + attrs.mdfile + '\'"></div>'
            }).then((function() {
              return console.log(' Closed ' + attrs.mdfile);
            }),
    function() {
              return console.log(' Dismissed' + attrs.mdfile);
            });
          });
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=modal.js.map
