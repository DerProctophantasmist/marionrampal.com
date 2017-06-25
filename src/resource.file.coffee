module.exports = 'resourceFile'


resourceUrl = (url,title,text) ->  
  escape = (str)->
      #nueuuasrege!
      switch str
          when "\n"
              return "\\n"
          when "\""
              return "\\&quot;"
      return str
      
  resourceFile = url.match(/\.([^.]+)$/)
  if resourceFile 
    switch resourceFile[1] #the extension
      when 'md' #treat as markdown      
      
        text?= "";
        title?= "";
        html =  '<include-markup content="{&quot;filename&quot;:&quot;' + url +
                '&quot;,&quot;caption&quot;:&quot;' + title +
                '&quot;,&quot;chapeau&quot;:&quot;' + text.replace(/[\n\\\"]/g,escape) + '&quot;,' +
                '&quot;inline&quot;:' + true +
                '}" popup-links="popupLinks"></include-markup>'
                
        return {
          html: html
        }
      when 'i18n'  #treat as markdown, filename needs to be localised (include-markup takes care of that when we get rid of the extension)   
        url = url.substr(0, url.length -5)      
      
        text?= "";
        title?= "";
        html =  '<include-markup content="{&quot;filename&quot;:&quot;' + url +
                '&quot;,&quot;caption&quot;:&quot;' + title +
                '&quot;,&quot;chapeau&quot;:&quot;' + text.replace(/[\n\\\"]/g,escape) + '&quot;,' +
                '&quot;inline&quot;:' + true +
                '}" popup-links="popupLinks"></include-markup>'
  return false

require('angular').module('resourceFile', ['config'])
  .constant('ResourceFile', resourceUrl)

 