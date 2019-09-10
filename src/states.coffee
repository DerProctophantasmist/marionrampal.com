module.exports = 'states'

require('angular').module('states', [require('angular-ui-router'),require('angular-scroll'), require('./menu'),require('./data.provider')])
  .config(['$stateProvider' , '$urlRouterProvider', '$locationProvider', 
  ($stateProvider,$urlRouterProvider,$locationProvider) ->
#    $urlRouterProvider.otherwise("/loading")

    $urlRouterProvider.otherwise("/home")
#    
#    $stateProvider.state('loading', {      
#      url: "/loading/:url"
#    })
    
    
    $stateProvider.state('home',{
      url:'/'
    })
#    
#    $stateProvider.state('loading.done', {    
#      onEnter: ['$stateParams','$location', ($stateParams, $location) ->
#        $location.path($stateParams.url).replace()
#        return
#      ]
#    })
    
    $stateProvider.state('section', {
      url: "/:id", 
      onEnter: ['$stateParams','$document', '$timeout', 'Sections', 'State', '$state', ($stateParams,$document, $timeout, Sections, State, $state) ->  
        
        Sections.onLoad( (section) ->        
            if  section.id.toLowerCase() == $stateParams.id.toLowerCase()
              State.sectionToDisplay = section          
          ,
          () ->            
            if State.sectionToDisplay == null
              console.log "Incorrect section: " + $stateParams.id
              $state.go('home')
            return
          )
        return
      ]    
    })
#    
#    $stateProvider.state('page', {
#      url: "/page/:id", 
#      onEnter: ['$stateParams','$document', ($stateParams,$document) ->  
#        return
#      ]    
#    })
    
    $locationProvider.html5Mode(true)
    return
  ])
  .run([ '$state', '$location', 'State', 'Sections', ( $state, $location,State, Sections) ->
    path = $location.path()
    console.log $location.path()
    
          

    
#    $state.go('loading', { url: path}, {location: 'replace' })
    
  ])
  .factory('State', ['$state', '$stateParams', ($state, $stateParams) ->
    State = {
      singleSection : () ->
        return $state.current.name == 'section'
      ,      
      isSectionToDisplay : (sectionName) ->
        return !State.singleSection() && !State.hiddenSections[sectionName] || (sectionName.toLowerCase() == $stateParams.id.toLowerCase());
      ,
      sectionToDisplay : null,
      hiddenSections: [],
      home: (()-> $state.go('home');return)
    }
      
    
    return State;
  ])