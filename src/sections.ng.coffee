
require('angular').module('sections',[require('./language.picker')])
  .factory 'Sections',['Locale'
  , ( Locale) -> 

    sections = require('./sections')

    sections.registerSectionData = (sectionData) ->
      section = sections.data[sectionData.id]
      if !section #we prerendered the markdown on the server, and we need to register the section here. 
        section = sections.registerSection sectionData
      else #we did not prerender the markdown on the server, and we registered all the sections on the client when processing it (the markdown),
      # so that they be correctly ordered (otherwise registering after fetching the md files asynchronously would result in random ordering)
        for key, value of sectionData 
          section[key]=value

      section.getname = getname
      sections.loadedOneSection()
      return section
      
    
    getname = () ->
      return this.name if typeof this.name == "string"
      return this.name[Locale.get().language]
    
              
    return sections
  ]  
  
module.exports = 'sections'