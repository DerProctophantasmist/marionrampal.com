
module.exports = 'menu'
baseParams = 
          windowClass: 'main-menu',
          backdrop: true,
          controller: ['$scope', '$uibModalInstance', 'Sections', 'State', ($scope, $uibModalInstance,Sections, State) ->
            #on opening the menu we navigate back to the home state, so that all "pages" are available.
            State.home();
            this.title = 'Menu'
            this.ok = (e) ->
              $uibModalInstance.close();
              e.stopPropagation() if e
            this.cancel = (e) ->
              $uibModalInstance.dismiss();
              e.stopPropagation() if e
            this.sections = Sections.data
            return this
          ],
          controllerAs:'MenuCtrl'

makeMenu = (params)-> #params is an object must include placement and template or templateUrl 
  ($aside) ->
    menu = null

    return {
      open: ->
        if menu != null
          console.log "trying to open main menu while it already is"
          return menu
        menu = $aside.open({ baseParams..., params... });
        menu.result.then(( ->
            console.log('Closed menu')
            menu = null
          ),( ->             
            console.log('Dismissed menu')
            menu = null
        ))           
        return menu.result;
      isOpen: ->
        return menu != null
      close: ->
        if menu == null 
          console.log("trying to close main menu while not open")
          return
        menu.close()
      dismiss: ->
        if menu == null 
          console.log("trying to dismiss main menu while not open")
          return
        menu.dismiss()        
    }

require('angular').module('menu', [require('angular-aside'), require('./states')]).
  factory('Menu', ['$aside', (makeMenu  {placement: 'right', templateUrl: 'templates/menu.html'})
  ])
  .directive("mainMenu", ['Menu' , (Menu)->
      restrict: 'A',
      scope:false
      replace: false, 
      link: (scope,elt,attrs) ->
        elt.on('click', () -> 
          Menu.open().then ( -> console.log(' Closed menu 2')), ->
            console.log(' Dismissed menu 2')
        )
  ])
  .factory('GetInTouch',  ['$aside', (makeMenu {placement: 'left', template: '<marked compile=true filename="getInTouch"></marked>'})
  ])
  .directive("getInTouch", ['GetInTouch' , (Menu)->
      restrict: 'A',
      scope:false
      replace: false, 
      link: (scope,elt,attrs) ->
        elt.on('click', () -> 
          Menu.open().then ( -> console.log(' Closed get in touch')), ->
            console.log(' Dismissed get in touch')
        )
  ])