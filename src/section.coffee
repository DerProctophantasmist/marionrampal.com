module.exports = 'section'

require('angular').module('section',[])
.component('section', {
  template: '<ng-transclude ng-if="!$c.empty"></ng-transclude>',
  transclude: true,
  bindings: {section: '<'},
  controller: ['Calendars', '$scope', (Calendars, $scope) ->        
      this.empty = false
      this.$onInit = ()=>
        if this.section.emptyEvent
          $scope.$on( this.section.emptyEvent, 
              (e, args)=>
                this.empty = true
                next = this.section.pages[this.section.pages.length - 1].next;
                if (previous = this.section.pages[0].previous)?
                  previous.next = next
                if next?
                  next.previous = previous
            )
        return
      return
      
    ],
  controllerAs: '$c'
})
