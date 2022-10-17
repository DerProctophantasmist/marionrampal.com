module.exports = 'preloaded'

require('angular').module('preloaded',[require('./sections.ng'), require('./language.picker')])
.directive('preloaded', () -> 
  {
    template: """
      <ng-transclude ng-if="$preloadedCtrl.preloaded"></ng-transclude><div marked ng-if="!$preloadedCtrl.preloaded" filename="$preloadedCtrl.entryFile" compile=true></div>
    """,
    transclude: true,
    bindToController: {entryFile: '@', nbrOfSections: '@'},
    controller: ['Locale', 'Sections', '$scope', (Locale, Sections,$scope) ->        
        this.preloaded = true

        reload = ()=>
          this.preloaded=false
          Locale.offChange(reload)

        # Locale.onChange(reload)
          
        this.$onInit = ()=>
          Sections.nbrOfSectionsToLoad(1) # the section data is preloaded, we don't have to wait to execute the callbacks
        return
        
      ],
    controllerAs: '$preloadedCtrl'
  }
)