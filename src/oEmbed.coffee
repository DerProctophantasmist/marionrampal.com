module.exports = 'oEmbed'

#we actually accept all resources based on domain, not just oEmbed, for *.fnac.com for instance, we generate the html to include directly
#whereas for real oEmbed, we query the endpoint through the <o-embed directive> (note that for youtube we use the youtube API main reason 
#being their oEmbed doesn't implement CORS!)
require('angular').module('oEmbed', ['config'])
  .constant('EmbedUrl', require('./resourceUrl').embedUrl )
  .factory('oEmbed',['$http' , '$sce', 'Config', ($http, $sce, Config) ->
    
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
          parameters = url.match(/([a-z\:\/]*\/\/)(?:www\.)?(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:\?(?:index=[0-9]+&amp;)?(?:list=)?([a-zA-Z0-9_-]{34})?)?/)
          if !parameters
            callback({err:new Error("not a youtube url")})
            return false

          playlist = if parameters[3] then parameters[3] else Config.defaultYoutubePlaylist
          videoId = parameters[2]
          protocol = parameters[1]           
          resource =  {
            resource...,          
            request: "https://www.googleapis.com/youtube/v3/videos?part=snippet&id="+videoId+"&fields=items(snippet(thumbnails(medium(url))))&key="+Config.googleApiKey,
            playlist: playlist,
            'video-id': videoId,
            protocol: protocol
          }
        else if resource.provider == 'soundcloud'

          #detect whether it is a track or a playlist and adjust height accordingly:
          height = if url.indexOf('/sets/') != -1 then 305 else 110            
          resource = {
            resource...
            request: "https://soundcloud.com/oembed?format=json&visual=false&maxheight="+height+"&color=000000&show_comments=false&show_artwork=true&url=" + url
          }
          
          headers['Cache-Control'] = undefined
          headers["Content-Type"] = "text/plain"
        else if resource.provider == "vimeo"
          resource = {
            resource...
            request:"https://vimeo.com/api/oembed.json?autoplay=true&autopause=true&portrait=false&color=white&url="  + url
          }
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
                callback {err: new Error( "BEWARE: the youtube video: " + resource.url + " is probably private. It won't be rendered.")}
                return              
              thumbnail_url = response.data.items[0].snippet.thumbnails.medium.url
              response.data.html ='<a popup-link="video" class="image half centered popup-link" data-url="https://www.youtube.com/watch?v=' + resource["video-id"] + '" content-settings="{&quot;list&quot;:&quot;' + resource.playlist +
              '&quot;}"><img src="' + thumbnail_url + '" /><span class="play-button"></span></a>'
              response.data.compile = true
          confs[url] = response.data
          callback(response.data)
        ,(response) -> 
          callback {err: new Error('Could not load '+url+' : ' + JSON.stringify(response))}
          return
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
        if(attrs.provider?)
          res = attrs

          oEmbed(scope.url, res, (response)->
              if response.err 
                console.log response.err
                return
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

 