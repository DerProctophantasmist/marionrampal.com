module.exports = 'markedConfig'
Config = require('./config.data.js')

require('angular').module('markedConfig', [require('angular-marked'), require('./oEmbed'), require('./config'), require('./resource.file')])
  .config(['markedProvider', 'OEmbedUrl', 'ResourceFile', (markedProvider, OEmbedUrl, ResourceFile) ->  
    
    marked = require('marked')
    oldRenderer = new marked.Renderer()
    renderer = {
      link :  ( href, title, text) ->
        if (res = OEmbedUrl href) || (res = ResourceFile(href,title,text))
          return res.html;
        else 
          return oldRenderer.link(href,title,text)
      ,
      heading: (text, level,raw) ->
        if level > 3 then return oldRenderer.heading(text,level,raw)
        escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')
        return '<h' + level + ' class="special-font" ><a name="' +
          escapedText +
          '" class="anchor" href="#' +
          escapedText +
          '"><span class="header-link"></span></a>' +
          text + '</h' + level + '>';
       
      ,
      image : ( href, title, text) ->
        if (res = OEmbedUrl href) 
          if ! (res.provider == text) then console.error('embeding failed for: ' + href + 'service ('+title+') doesn\'t match the one in the url ('+provider+')')
          return res.html;
        else 
          return '<img class="image centered half" src="'+href+'" alt="'+text+'" title="'+title+'" >'
          
       
    } 
      
    
    markedProvider.setOptions({gfm: true})
    markedProvider.setRenderer(renderer)
  ])


    
