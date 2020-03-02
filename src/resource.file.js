// Generated by CoffeeScript 2.5.1
(function() {
  var escape, markdownEmbed, markdownLinkTo, resourceUrl;

  module.exports = 'resourceFile';

  escape = function(str) {
    //nueuuasrege!
    switch (str) {
      case "\n":
        return "\\n";
      case "\"":
        return "\\&quot;";
    }
    return str;
  };

  markdownLinkTo = function(url, chapeau) {
    return '<include-markup content="{&quot;filename&quot;:&quot;' + url + '&quot;,&quot;chapeau&quot;:&quot;' + chapeau.replace(/[\n\\\"]/g, escape) + '&quot;,' + '&quot;inline&quot;:' + (chapeau !== "" ? 'true' : 'false') + '}" popup-links="popupLinks"></include-markup>';
  };

  markdownEmbed = function(url, title, text) {
    return '<div marked filename="&quot;' + url + '&quot;" compile="true" ></div> ';
  };

  resourceUrl = function(url, title, text, embed) {
    var genHtml, html, resourceFile;
    genHtml = embed ? markdownEmbed : markdownLinkTo;
    resourceFile = url.match(/\.([^.]+)$/);
    if (resourceFile == null) {
      resourceFile = [url];
    }
    switch (resourceFile[1]) {
      case 'md': //treat as markdown      
        if (title == null) {
          title = (text != null ? text : text = ""); // if title is empty, use text instead to create the chapeau
        }
        break;
      case 'i18n': //treat as markdown, filename needs to be localised (include-markup takes care of that when we get rid of the extension)   
        url = url.substr(0, url.length(-5));
        if (title == null) {
          title = (text != null ? text : text = ""); //file extension was not enough to deduce the nature of the link, text field will be used to determine it.
        }
        break;
      default:
        switch (text) {
          case 'markdown':
            if (title == null) {
              title = "";
            }
            break;
          default:
            return false; //not a resource link
        }
    }
    html = genHtml(url, title);
    return {
      html: html
    };
  };

  require('angular').module('resourceFile', ['config']).constant('ResourceFile', resourceUrl);

}).call(this);

//# sourceMappingURL=resource.file.js.map
