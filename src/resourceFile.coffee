
{markdownLinkTo, markdownEmbed} = require('./resourceFile.impl')
CSON = require("cson-parser")

escape = (str)->
    #nueuuasrege!
    switch str
        when "\n"
            return "\\n"
        when "\""
            return "\\&quot;"
    return str


resourceFile = (url,title,text,embed) ->  
  genHtml = if embed then markdownEmbed else markdownLinkTo
  inline = false
  if title then title = title.replace(/[\n\\\"]/g,escape)
  content = {filename:url, chapeau: title ? "", inline: false }


  
  switch text
    when 'markdown'
      break
    when 'inline'
      content.inline = true # inline is for link type only, makes no sense for embed
    else 
      try #text is CSON 
        content = {content..., (CSON.parse text.replace(/(&#39;)|(&quot;)/g, (sub)->
          switch sub  
            when "&#39;"
              return "'"
            when "&quot;"
              return '"'
        ))... }
      catch#check the file extension to see if it is a markdown file
        file = url.match(/\.([^.]+)$/)
        return false if !file?[1]? #no extension
        if !title 
          content.chapeau = text ? ""
        switch file[1] 
          when 'md' #treat as markdown 
            break
          when 'i18n'  #treat as markdown, filename needs to be localised (include-markup takes care of that when we get rid of the extension)   
            content.filename = url.substr(0, url.length -5)     
          else return false #not a resource link
   
  
   
  html =  genHtml(content) 
          
  return {
    html: html
  } 

module.exports = resourceFile
 
 