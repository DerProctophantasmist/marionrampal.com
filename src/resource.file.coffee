module.exports = 'resourceFile'

escape = (str)->
    #nueuuasrege!
    switch str
        when "\n"
            return "\\n"
        when "\""
            return "\\&quot;"
    return str

markdownLinkTo = (url, chapeau) ->
  return '<include-markup content="{&quot;filename&quot;:&quot;' + url +
        '&quot;,&quot;chapeau&quot;:&quot;' + chapeau.replace(/[\n\\\"]/g,escape) + '&quot;,' +
        '&quot;inline&quot;:' + (if chapeau != "" then 'true' else 'false') +
        '}" popup-links="popupLinks"></include-markup>'

markdownEmbed = (url, title, text) ->
  return '<div marked filename="&quot;' + url + '&quot;" compile="true" ></div> '


resourceUrl = (url,title,text,embed) ->  
  genHtml = if embed then markdownEmbed else markdownLinkTo
      
  resourceFile = url.match(/\.([^.]+)$/)
  resourceFile?= [url]
  switch resourceFile[1] #the extension
    when 'md' #treat as markdown      
    
      title?= (text?= ""); # if title is empty, use text instead to create the chapeau
    when 'i18n'  #treat as markdown, filename needs to be localised (include-markup takes care of that when we get rid of the extension)   
      url = url.substr(0, url.length -5)     
      title?= (text?= "")
    else #file extension was not enough to deduce the nature of the link, text field will be used to determine it.
      switch text
        when 'markdown'
          title?= ""
        else return false #not a resource link

   
  html =  genHtml(url, title)
          
  return {
    html: html
  } 

require('angular').module('resourceFile', ['config'])
  .constant('ResourceFile', resourceUrl)

 