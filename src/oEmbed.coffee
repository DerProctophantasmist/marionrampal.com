module.exports = 'oEmbed'
Config = require('./config.data.js')


attributeString = (object) ->
  ret = " "
  for own key, value of object
    ret += key+'="' +value.replace(/"/g,"&quote;")+ '" '
  return ret

resourceUrl = (url) ->
  provider = url.match(/https?:\/\/(?:[^./]+\.)?([^./]+(?:\.[^./]+)+)/)
  res = false
  if provider 
    switch provider[1]
      when 'soundcloud.com' 
        #detect whether it is a track or a playlist and adjust height accordingly:
        height = if url.indexOf('/sets/') != -1 then 305 else 110
          
        res =  {
          request: "http://soundcloud.com/oembed?type=json&visual=false&maxheight="+height+"&color=000000&show_comments=false&show_artwork=true&url=" + url,
          provider: "soundcloud"
        }
      when 'youtu.be', 'youtube.com'
        parameters = url.match(/([a-z\:\/]*\/\/)(?:www\.)?(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:&amp;index=[0-9]+)?(?:&amp;list=)?([a-zA-Z0-9_-]{34})?/)
        if parameters
          playlist = if parameters[3] then parameters[3] else Config.defaultYoutubePlaylist
          videoID = parameters[2]
          protocol = parameters[1]
        res =  {          
          request: "https://www.googleapis.com/youtube/v3/videos?part=snippet&id="+videoID+"&fields=items(snippet(thumbnails(medium(url))))&key="+Config.googleApiKey,
#          request: 'http://www.youtube.com/oembed?url=' +url,
          provider: "youtube",
          playlist: playlist,
          videoID: videoID,
          protocol: protocol
        }
      when 'vimeo.com'
        res =  {
          request:"https://vimeo.com/api/oembed.json?autoplay=true&autopause=true&portrait=false&color=white&url="  + url,
          provider: 'vimeo'
        }
      when 'fnac.com'
        res =  {
          html: '<a href="'+url+'" /><span class="icon-fnac"></span></a>'
        }        
      when 'qobuz.com'
        res =  {
          html: '<a href="'+url+'" /><span class="icon-qobuz"></span></a>'
        }   
      when 'spotify.com'
        res =  {
          html: '<a href="'+url+'" /><span class="icon-spotify"></span></a>'
        }
      when 'amazon.com', 'amazon.co.uk', 'amazon.de', 'amazon.fr', 'amazon.be'
        res =  {
          html: '<a href="'+url+'" /><span class="icon-amazon"></span></a>'
        }
  if res then res.url = url
  return res

#we actually accept all resources based on domain, not just oEmbed, for *.fnac.com for instance, we generate the html to include directly
#whereas for real oEmbed, we query the endpoint through the <o-embed directive> (note that for youtube we use the youtube API main reason 
#being their oEmbed doesn't implement CORS!)
require('angular').module('oEmbed', ['config'])
  .constant('OEmbedUrl', (url) -> 
      res = resourceUrl(url) 
      if res && !res.html  
        res.html = '<o-embed' + attributeString(res) + '></o-embed>'
      return res
  )
  .factory('oEmbed',['$http' , '$sce', ($http, $sce) ->
    
    confs = {}
    
         
    load = (url, callback, resource) -> 
      
      if( resource ?= resourceUrl(url))
        $http.get(resource.request ).then (response) ->        
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
              thumbnail_url = response.data.items[0].snippet.thumbnails.medium.url
              response.data.html ='<a popup-link="video" class="image half centered popup-link" data-url="https://www.youtube.com/watch?v=' + resource.videoID + '" content-settings="{&quot;list&quot;:&quot;' + resource.playlist +
              '&quot;}"><img src="' + thumbnail_url + '" /><span class="play-button"></span></a>'
              response.data.compile = true
          confs[url] = response.data
          callback(response.data)
        ,(response) -> console.log 'Could not load '+url+' : ' + JSON.stringify(response)
        return true
      else return false
      
    
    return (url, callback) ->
      if !confs[url]
        return load(url, callback)
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
        scope.$watch('url', ()->
          oEmbed(scope.url, (response)->
              if response.compile
                elt.append($compile(response.html)(scope.$new(false)))
              else
                elt.append(response.html)
            ,
            res
          )
          return    
        )
  ])

 