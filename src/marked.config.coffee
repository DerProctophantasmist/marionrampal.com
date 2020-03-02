module.exports = 'markedConfig'
Config = window.config

require('angular').module('markedConfig', [require('angular-marked'), require('angular-ui-bootstrap'), require('./oEmbed'), require('./config'), require('./resource.file')])
.config(['markedProvider', 'OEmbedUrl', 'ResourceFile', (markedProvider, OEmbedUrl, ResourceFile) ->  
  
  marked = require('marked')
  oldRenderer = new marked.Renderer()
  carouselRenderer = new marked.Renderer() 
  carouselRenderer.listitem = (text, task, checked) -> 
    console.log "listitem:"
    console.log text
    console.log task
    console.log checked  
    return '<div class="uibslide" uib-slide >' + text + '</div>'
  carouselRenderer.list = (body,ordered, start) ->
    console.log "list:"
    console.log body
    console.log ordered
    console.log start
    return '<div carousel-ctrl><div uib-carousel>' +  body + '</div></div>'


  console.log carouselRenderer

  renderer = {
    link :  ( href, title, text) ->
      if  res = ResourceFile(href,title,text,false) #last param is embed=true/false
        return res.html;
      else 
        return oldRenderer.link(href,title,text)
    ,
    # heading: (text, level,raw,slugger) ->
    #   if level > 3 then return oldRenderer.heading(text,level,raw,slugger)
    #   escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')
    #   return '<h' + level + ' class="special-font" ><a name="' +
    #     escapedText +
    #     '" class="anchor" href="#' +
    #     escapedText +
    #     '"><span class="header-link"></span></a>' +
    #     text + '</h' + level + '>';
      
    # ,
    image : ( href, title, text) ->
      if (res = OEmbedUrl(href) || res = ResourceFile(href, title, text, true) )
        if res.provider && ! (res.provider == text) then console.error('embeding failed for: ' + href + 'service ('+title+') doesn\'t match the one in the url ('+res.provider+')')
        return res.html;
      else 
        return '<img class="image centered half" src="'+href+'" alt="'+text+'" title="'+title+'" >'
    ,  
    code:  (code,  infostring,  escaped) ->
        console.log code
        console.log infostring
        console.log escaped
        
        if infostring && infostring.toLowerCase() == "carousel"
          return  marked(code, { renderer: carouselRenderer }) 
    # list : (body,ordered, start) ->
    #   console.log "list:"
    #   console.log body
    #   console.log ordered
    #   console.log start
    #   return oldRenderer.list(body,ordered,start)
    # ,
      
  } 
    
  
  markedProvider.setOptions({gfm: true, breaks: false})
  markedProvider.setRenderer(renderer)
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
    
