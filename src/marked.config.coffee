module.exports = 'markedConfig'
registerNbrOfSections = require('./marked.utils')
marked = require('marked')



require('angular').module('markedConfig', [require('angular-marked'), require('angular-ui-bootstrap'), require('./oEmbed'), require('./sections'), require('./resource.file')])
.config(['markedProvider', 'EmbedUrl', 'ResourceFile', (markedProvider, EmbedUrl, ResourceFile) ->  
  console.log "marked defaults"
  console.log marked.defaults
  markedProvider.setOptions(marked.defaults)
  markedProvider.setRenderer(marked.defaults.renderer)
])
.run(['Sections',(Sections)->
  registerNbrOfSections(Sections.nbrOfSectionsToLoad)
])
.directive('carouselCtrl', () ->
    template: "<div ng-transclude></div>"
    transclude: true
    scope:{}
    controller: [() ->        
      this.active = 0;
      return;      
    ]
    controllerAs: 'cc'
    link: (scope,element, attrs) ->
      elt = element[0]
      slides = elt.querySelectorAll("div[uib-slide]")
      console.log elt
      console.log slides
      for i in [0..(slides.length-1)]
        listitem = slides[i]        
        listitem.setAttribute("index",i)
        console.log "item" + i
        console.log listitem
      
)
    
