module.exports = 'section'

require('angular').module('section',[require('./sections'), require('./states')])
.component('section', {
  template: '<ng-transclude ng-if="!$sc.empty"></ng-transclude>',
  transclude: true,
  bindings: {section: '<', sectionData: '@'},
  controller: ['State', 'Calendars', '$scope', 'Sections', (State, Calendars, $scope, Sections) ->        
      this.empty = false
        
      this.$onInit = ()=>
        if !this.section?
          try
            this.section = JSON.parse(this.sectionData)
          catch e
            console.log "data for the section is not well formed: " + e.toString()
            return
        Sections.addSection(this.section)
        if this.section.emptyEvent #this is used for calendars only for now, if if it's empty hide the section
        #why the hell do we hide the whole section and not just the page? Well we should hide the section
        #if it has a single page, which is the case, hence, more work. Just lazy.
          $scope.website = $scope.$parent.website
          #we don't want to hide the section if we are editing
          if !State.getAllowEdit()
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
  controllerAs: '$sc'
})
