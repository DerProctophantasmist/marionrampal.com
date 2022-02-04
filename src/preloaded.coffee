module.exports = 'preloaded'

require('angular').module('preloaded',[require('./sections'), require('./language.picker')])
.directive('preloaded', () -> 
  {
    template: """
      <ng-transclude ng-if="$preloadedCtrl.preloaded"></ng-transclude><marked ng-if="!$preloadedCtrl.preloaded" filename="$preloadedCtrl.entryFile" compile=true></marked>
    """,
    transclude: true,
    bindToController: {entryFile: '@', nbrOfSections: '@'},
    controller: ['Locale', 'Sections', '$scope', (Locale, Sections,$scope) ->        
        $scope.preloaded = true

        reload = ()=>
          $scope.preloaded=false
          Locale.offChange(reload)

        Locale.onChange(reload)
          
        this.$onInit = ()=>
          Sections.nbrOfSectionsToLoad(1) # the section data is preloaded, we don't have to wait to execute the callbacks
        return
        
      ],
    controllerAs: '$preloadedCtrl'
  }
)