module.exports = 'oEmbed'

#we actually accept all resources based on domain, not just oEmbed, for *.fnac.com for instance, we generate the html to include directly
#whereas for real oEmbed, we query the endpoint through the <o-embed directive> (note that for youtube we use the youtube API main reason 
#being their oEmbed doesn't implement CORS!)
require('angular').module('oEmbed', ['config'])
  .constant('EmbedUrl', require('./resourceUrl').embedUrl )
  .factory('oEmbed',['$http' , '$sce', ($http, $sce) ->
    
    confs = {}
    resourceUrl = require('./resourceUrl').resourceUrl
     
    
         
    load = (url, resource, callback) -> 
      
      if( resource ?= resourceUrl(url))
        headers = []
        if resource.provider in['akamai']
          response ={ 
            html:"""
              <a popup-link="video" class="image half centered popup-link" data-url="#{url}"  content-settings="{&quot;playerID&quot;:&quot;#{resource.playerId}&quot;}">
                <img src="#{resource.image}" /><span class="play-button"></span>
              </a>
            """
            compile: true
          }
          confs[url] = response.data
          callback(response)
          return true

        if resource.provider in ['youtube']
          headers['Cache-Control'] = 'no-cache'
        else if resource.provider == 'soundcloud'
          headers['Cache-Control'] = undefined
          headers["Content-Type"] = "text/plain"
        else if resource.provider == "vimeo"
          headers['Cache-Control'] = undefined

        $http({method:'get', url: resource.request, 'headers': headers} ).then (response) ->        
          if response.data.type == 'image'
            response.data.html = '<img class="image fit" src="' + response.data.src + '"></img>'
          switch( resource.provider)
            when 'soundcloud'
              #fucking soundcloud!
              response.data.html = response.data.html.replace('visual=true&','')
            when 'vimeo'
              response.data.html ='<a popup-link="video" class="image half centered popup-link" data-url="' + url + 
                                    '"><img src="' + response.data.thumbnail_url + '" /><span class="play-button"></span></a>'
              response.data.compile = true
            when 'youtube'
              if response.data.items.length == 0
                console.log "BEWARE: the youtube video: " + resource.url + " is probably private. It won't be rendered."
              else
                thumbnail_url = response.data.items[0].snippet.thumbnails.medium.url
                response.data.html ='<a popup-link="video" class="image half centered popup-link" data-url="https://www.youtube.com/watch?v=' + resource.videoId + '" content-settings="{&quot;list&quot;:&quot;' + resource.playlist +
                '&quot;}"><img src="' + thumbnail_url + '" /><span class="play-button"></span></a>'
                response.data.compile = true
          confs[url] = response.data
          callback(response.data)
        ,(response) -> console.log 'Could not load '+url+' : ' + JSON.stringify(response)
        return true
      else return false
      
    
    return (url, res, callback) ->
      if !confs[url]
        return load(url, res, callback)
      else
        callback(confs[url])
        return true
    
  ])
  .directive('oEmbed', ['oEmbed' ,  '$compile', (oEmbed, $compile)->
      restrict: 'E',
      scope:{'url':'@'}
      replace: true, 
      link: (scope,elt,attrs) ->
        scope.popupLinks = scope.$parent.popupLinks;
        if(attrs.request? && attrs.provider?)
          res = attrs

          oEmbed(scope.url, res, (response)->
              if response.compile
                elt.append($compile(response.html)(scope.$new(false)))
              else
                elt.append(response.html)
          )
        
        # scope.$watch('url', ()->
        #   oEmbed(scope.url, (response)->
        #       if response.compile
        #         elt.append($compile(response.html)(scope.$new(false)))
        #       else
        #         elt.append(response.html)
        #     ,
        #     res
        #   )
        #   return    
        # )
  ])

 