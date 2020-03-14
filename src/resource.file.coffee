module.exports = 'resourceFile'

escape = (str)->
    #nueuuasrege!
    switch str
        when "\n"
            return "\\n"
        when "\""
            return "\\&quot;"
    return str

markdownLinkTo = (url, chapeau, inline) ->
  return '<include-markup content="{&quot;filename&quot;:&quot;' + url +
        '&quot;,&quot;chapeau&quot;:&quot;' + chapeau.replace(/[\n\\\"]/g,escape) + '&quot;,' +
        '&quot;inline&quot;:' + (if inline then 'true' else 'false') +
        '}" popup-links="popupLinks"></include-markup>'

markdownEmbed = (url, title) ->
  return '<div marked filename="&quot;' + url + '&quot;" compile="true" ></div> '


resourceUrl = (url,title,text,embed) ->  
  genHtml = if embed then markdownEmbed else markdownLinkTo
  inline = false

  
  switch text
    when 'markdown'
      title?= ""
    when 'inline'
      inline = true # this is for link type only, makes no sense for embed
      title?= ''
    else #check the file extension to see if it is a markdown file
      resourceFile = url.match(/\.([^.]+)$/)
      return false if !resourceFile[1]? #no extension
      switch resourceFile[1] 
        when 'md' #treat as markdown             
          title?= (text?= ""); # if title is empty, use text instead to create the chapeau
        when 'i18n'  #treat as markdown, filename needs to be localised (include-markup takes care of that when we get rid of the extension)   
          url = url.substr(0, url.length -5)     
          title?= (text?= "")
        else return false #not a resource link

   
  html =  genHtml(url, title, inline)
          
  return {
    html: html
  } 

require('angular').module('resourceFile', ['config'])
  .constant('ResourceFile', resourceUrl)

 