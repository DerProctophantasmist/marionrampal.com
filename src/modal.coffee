
module.exports = 'menu'
baseParams = 
          windowClass: 'main-menu',
          backdrop: true,
          controller: ['$scope', '$uibModalInstance', 'Sections', 'State', '$http', ($scope, $uibModalInstance,Sections, State, $http) ->
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
            this.showAdmin = State.getAllowEdit
            if State.getAllowEdit()
              this.adminCommit = adminCommand.bind(this, $http, './commit', 'Successfully commited changes', 'Error, changes where not commited.', (err)=>this.ok())                
              this.adminUnstage = adminCommand.bind(this, $http, './unstage', 'Successfully unstaged changes', 'Error, changes where not unstaged.', (err)=> if err then this.ok() else window.location.reload())
            return this
          ],
          controllerAs:'MenuCtrl'

adminCommand = ($http, url, msgSuccess, msgError, callback) ->         
  $http.post(url,"").then (res)->
      alert(msgSuccess)
      callback()
    ,
    (res) -> 
      alert(msgError) + "\n" +  res.data.txt
      callback(new Error(res.data.txt))


makeMenu = -> 
  ($aside) ->
    menu = null

    return {
      open: (params) -> #params is an object must include placement and template or templateUrl 
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
  factory('Menu', ['$aside', (makeMenu())
  ])
  .directive("mainMenu", ['Menu' , (Menu)->
      restrict: 'A',
      scope:false
      replace: false, 
      link: (scope,elt,attrs) ->
        elt.on('click', () -> 
          Menu.open( {placement: 'right', templateUrl: 'templates/menu.html'}).then ( -> console.log(' Closed menu 2')), ->
            console.log(' Dismissed menu 2')
        )
  ])
  .factory('LeftAside',  ['$aside', (makeMenu())
  ])
  .directive("leftAside", ['LeftAside' , (Menu)->
      restrict: 'A',
      scope:false
      replace: false, 
      link: (scope,elt,attrs) ->
        
        elt.on('click', () -> 
          Menu.open( {placement: 'left', template: '<div class="sidebar menu" style="height:100%;width:100%" marked compile=true filename="\''+attrs.mdfile+'\'"></div>'})
          .then ( -> console.log(' Closed '+ attrs.mdfile )), ->
            console.log(' Dismissed' + attrs.mdfile)
        )
  ])