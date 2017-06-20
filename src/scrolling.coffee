module.exports = 'scrolling'

require('angular-inview');
debounce = require('debounce');

 

require('angular').module('scrolling', ['angular-inview', require('angular-scroll')])
.run(['$window','$document', '$rootScope', ($window, $document, $rootScope)->

  adjust = (article) ->
    elt = article[0]
    #include padding borders and margins:
    articleRect = elt.getBoundingClientRect()
    articleHeight = articleRect.bottom - articleRect.top
    top = $document.scrollTop()

    offset = articleRect.top
    windowsHeight = $window.innerHeight

    #if the article is bigger than the window, we scroll to the bottom of the
    #article if it's nearer than the top
    if (articleHeight > windowsHeight) 
        offsetBottom = articleRect.bottom - windowsHeight
        if (Math.abs(offset) > Math.abs(offsetBottom))
            offset = offsetBottom


    if offset > -windowsHeight / 2 && (if article.hasClass('full-gravity') then offset < windowsHeight / 2 else offset < windowsHeight / 10)
      duration = Math.min(Math.abs(offset) * 10, 750)
  #                    $page.on("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove", function () {
  #                        $page.stop()
  #                    })
      $document.scrollTop(top + offset,duration)
  #                    $page.animate({scrollTop: top - offset}, {duration: duration, always: function () {
  #                            $page.off("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove")
  #                        }})

  angular.element($window).on("scroll", () ->
    $rootScope.$apply( ()->
      
      #debounce( adjust, 250)(article)

    )
  )
])

.factory('Activate', ['Sections', '$window', '$document', (Sections, $window, $document) ->

        return {
          page:  (isInView, page, info) ->
            event=info.event
            if info.changed
              page.active = isInView
              
              if isInView && (page.previous == null || !page.previous.active)
                Sections.topPage = page
                console.log(Sections.topPage.section.getname())              
                         
            if !isInView 
              if Sections.topPage == page && page.next.active
                Sections.topPage = page.next

        }
    ])

  