
markdownLinkTo = (url, chapeau, inline) ->
  return '<include-markup content="{&quot;filename&quot;:&quot;' + url +
        '&quot;,&quot;chapeau&quot;:&quot;' + chapeau.replace(/[\n\\\"]/g,escape) + '&quot;,' +
        '&quot;inline&quot;:' + (if inline then 'true' else 'false') +
        '}" popup-links="popupLinks"></include-markup>'

markdownEmbed = (url, title) ->
  return '<div marked filename="&quot;' + url + '&quot;" compile="true" ></div> '


includePageFile = (url) ->"""  
    <marked compile=true filename="'#{url}'" editor-button-style="position:absolute;top:6em;left:10em;color:black;z-index:1000;">
  """


includeSectionFile = (url) -> """
    <marked compile=true filename="'#{url}'" editor-button-style="position:absolute;top:3em;left:10em;color:black;z-index:1000;">
    """

module.exports = 
  markdownLinkTo:markdownLinkTo
  markdownEmbed:markdownEmbed
  includePageFile:includePageFile
  includeSectionFile:includeSectionFile