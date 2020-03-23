require('./utils.js')

module.exports = "renderJson"
require('angular').module('renderJson',[])
  .factory( 'JsonRenderer',[() ->     

    escape = (str) ->            
      #nueuuasrege!
      switch str          
        when "\n"
          return "\\n"
        when "\""
          return "\\&quot;"   
      return str

    htmlXtension = {
      youtube: (config) ->
        config.playlist = config.playlist || Config.defaultYoutubePlaylist;
        return '<a popup-link="video" style="position:relative;" class="image half centered popup-link" data-url="https://www.youtube.com/watch?v=' + config.id + '" content-settings="{&quot;list&quot;:&quot;' + config.playlist +
          '&quot;}"><img src="//img.youtube.com/vi/' + config.id + '/hqdefault.jpg" /><span class="play-button"></span></a>';
      ,
      'google-calendar': (config) ->
        return '<google-calendar id="' + config.id + '"></google-calendar>'
      ,
      'include-markup': (config) ->
        if (!config.filename)
          console.log("include-markup should define the filename attribute")
          return ""
        config.caption = config.caption || "";
        config.chapeau = config.chapeau || "";
        config.inline = Boolean(config.inline) || false;
        config.main = Boolean(config.main) || false;

        if typeof config.chapeau == "object" #i18n
          chapeau = '{'
          i = 0;
          for key, value of config.chapeau
            chapeau += (if i then  ',' else '') + '&quot;'+ key + '&quot;:&quot;' + value.replace(/[\n\\\"]/g,escape) + '&quot;'
            ++i;
          chapeau += '}';
          config.chapeau = chapeau              
        else config.chapeau = '&quot;' + config.chapeau.replace(/[\n\\\"]/g,escape) + '&quot;'

        return '<include-markup content="{&quot;filename&quot;:&quot;' + config.filename +
          '&quot;,&quot;caption&quot;:&quot;' + config.caption +
          '&quot;,&quot;chapeau&quot;:' + config.chapeau + ',' +
          '&quot;inline&quot;:' + config.inline +
          ',&quot;main&quot;:' + config.main +
          '}" popup-links="popupLinks"></include-markup>'
    }
  
    root = (json) ->
      if typeof json == "string"
        return json
      else if Array.isArray(json)
        return elts json, 0


    elts = (json, i) ->
      if json.length == i 
        return "" 
      else 
        html = elt(json[i]) + elts(json, i + 1)
        return html

    elt = (json) ->
      switch typeof json
        when "string" 
          return '<marked compile="true">'+json+'</marked>'
        when "object"
          if json.xtended == undefined
            attrs = ""
            children = ""            
            for key, value of json
              if key[0] == '@'
                attrs += ' ' + key.substring(1) + '="' + value + '"'
              else 
                children = root value
                tag = key
            html = "<" + tag + attrs + ">" + children + "</" + tag + ">"
          else html = htmlXtension[json.xtended](json)        
      return html

    return root    
    
      
  ])

