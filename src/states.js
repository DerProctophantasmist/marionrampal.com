// Generated by CoffeeScript 2.6.1
(function() {
  module.exports = 'states';

  require('angular').module('states', [require('angular-ui-router'), require('angular-scroll'), require('./modal'), require('./sections')]).config([
    '$stateProvider',
    '$urlRouterProvider',
    '$locationProvider',
    function($stateProvider,
    $urlRouterProvider,
    $locationProvider) {
      //    $urlRouterProvider.otherwise("/loading")
      $urlRouterProvider.otherwise("/home");
      
      //    $stateProvider.state('loading', {       
      //      url: "/loading/:url"
      //    })
      $stateProvider.state('home',
    {
        url: '/'
      });
      
      //    $stateProvider.state('loading.done', {    
      //      onEnter: ['$stateParams','$location', ($stateParams, $location) ->
      //        $location.path($stateParams.url).replace()
      //        return
      //      ]
      //    })
      $stateProvider.state('section',
    {
        url: "/:id",
        onEnter: [
          '$stateParams',
          '$document',
          '$timeout',
          'Sections',
          'State',
          '$state',
          function($stateParams,
          $document,
          $timeout,
          Sections,
          State,
          $state) {
            Sections.onLoad(function(section) {
              if (section.id.toLowerCase() === $stateParams.id.toLowerCase()) {
                return State.sectionToDisplay = section;
              }
            },
          function() {
              if (State.sectionToDisplay === null) {
                console.log("Incorrect section: " + $stateParams.id);
                $state.go('home');
              }
            });
          }
        ]
      });
      
      //    $stateProvider.state('page', {
      //      url: "/page/:id", 
      //      onEnter: ['$stateParams','$document', ($stateParams,$document) ->  
      //        return
      //      ]    
      //    })
      $locationProvider.html5Mode(true);
    }
  ]).run([
    '$state',
    '$location',
    'State',
    'Sections',
    function($state,
    $location,
    State,
    Sections) {
      var path;
      path = $location.path();
      return console.log($location.path());
    }
  
  //    $state.go('loading', { url: path}, {location: 'replace' })
  ]).factory('State', [
    '$state',
    '$stateParams',
    function($state,
    $stateParams) {
      var State,
    hideMainContent;
      hideMainContent = false;
      State = {
        singleSection: function() {
          return $state.current.name === 'section';
        },
        isSectionToDisplay: function(sectionName) {
          return !State.singleSection() && !State.hiddenSections[sectionName] || (sectionName.toLowerCase() === $stateParams.id.toLowerCase());
        },
        sectionToDisplay: null,
        showEditors: false,
        hiddenSections: [],
        home: (function() {
          $state.go('home');
        }),
        isMainContentHidden: function() {
          return hideMainContent;
        },
        hideMainContent: function(value) {
          return hideMainContent = value !== false;
        },
        getCarouselInterval: function() {
          if (hideMainContent) {
            return 0;
          } else {
            return 5000;
          }
        },
        setAllowEdit: function(allowEdit) {
          return State.showEditors = allowEdit;
        },
        getAllowEdit: function() {
          return State.showEditors;
        }
      };
      return State;
    }
  ]);

}).call(this);

//# sourceMappingURL=states.js.map
