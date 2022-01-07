Config = window.config 


attributeString = (object) ->
  ret = " "
  for own key, value of object
    ret += key+'="' +value.replace(/"/g,"&quote;")+ '" '
  return ret

resourceUrl = (url,title, text) ->
  provider = url.match(/(?<protocol>https?:\/\/)(?<subdomain>[^./]+\.)?(?<domain>[^./]+(?:\.[^./]+)+)/)
  #note that subdomain includes the final '.'
  res = false
  if provider 
    switch provider.groups.domain
      when 'soundcloud.com' 
        #detect whether it is a track or a playlist and adjust height accordingly:
        height = if url.indexOf('/sets/') != -1 then 305 else 110
          
        res =  {
          request: "https://soundcloud.com/oembed?type=json&visual=false&maxheight="+height+"&color=000000&show_comments=false&show_artwork=true&url=" + url,
          provider: "soundcloud"
        }
      when 'youtu.be', 'youtube.com'
        parameters = url.match(/([a-z\:\/]*\/\/)(?:www\.)?(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:\?(?:index=[0-9]+&amp;)?(?:list=)?([a-zA-Z0-9_-]{34})?)?/)
        if parameters
          playlist = if parameters[3] then parameters[3] else Config.defaultYoutubePlaylist
          videoId = parameters[2]
          protocol = parameters[1] 
        res =  {          
          request: "https://www.googleapis.com/youtube/v3/videos?part=snippet&id="+videoId+"&fields=items(snippet(thumbnails(medium(url))))&key="+Config.googleApiKey,
#          request: 'http://www.youtube.com/oembed?url=' +url,
          provider: "youtube",
          playlist: playlist,
          'video-id': videoId,
          protocol: protocol
        }
      when 'vimeo.com'
        res =  {
          request:"https://vimeo.com/api/oembed.json?autoplay=true&autopause=true&portrait=false&color=white&url="  + url,
          provider: 'vimeo'
        }
      when 'akamaihd.net'
        res = {
          request: url
          provider: "akamai"
          'player-id': provider.groups.subdomain + provider.groups.domain 
          image: text ? ""
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


embedUrl = (url,title,text) -> 
  res = resourceUrl(url,title,text) 
  if res && !res.html  
    res.html = '<o-embed' + attributeString(res) + '></o-embed>'
  return res


module.exports = 
  embedUrl:embedUrl
  resourceUrl:resourceUrl