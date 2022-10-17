sections = require('./sections')

markdownLinkTo = (content) ->
  return '<include-markup content="{&quot;filename&quot;:&quot;' + content.filename +
        '&quot;,&quot;chapeau&quot;:&quot;' + content.chapeau + '&quot;,' +
        '&quot;inline&quot;:' + (if content.inline then 'true' else 'false') +
        '}" popup-links="popupLinks"></include-markup>'

markdownEmbed = (content) ->
  return '<div marked filename="&quot;' + content.filename + '&quot;" compile="true" ></div> '


includePageFile = (url) ->"""  
    <div marked compile=true filename="'#{url}'" editor-button-style="position:absolute;top:6em;left:10em;color:black;z-index:1000;">
    </div>
  """


includeSectionFile = (url, section) -> 
    sections.registerSection(section)
    """
    <div marked compile=true filename="'#{url}'" editor-button-style="position:absolute;top:3em;left:10em;color:black;z-index:1000;">
    </div>
    """


module.exports = 
  markdownLinkTo:markdownLinkTo
  markdownEmbed:markdownEmbed
  includePageFile:includePageFile
  includeSectionFile:includeSectionFile