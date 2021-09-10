
CSON = require 'cson-parser'

require('angular').module('sections',[require('./language.picker')])
  .factory 'Sections',['$http', 'Locale'
  , ($http, Locale) -> 
    delayedOnLoad = []
    onDone = null
    data = []
    nbrOfSectionsToLoad = -1
    nbrOfSectionsLoaded = 0

    execute = (func) ->
      for section in data
        func section
      return
     
    findPreviousPageBeforeInsertion = (section)->
      if section.pages.length
        return section.pages[section.pages.length - 1]
      if ! section.previous
        return null
      return findPreviousPageBeforeInsertion(section.previous)


    findNextPageBeforeInsertion = (section)->      
      if ! section.next
        return null
      if section.next.pages[0]
        return section.next.pages[0]
      return findNextPageBeforeInsertion(section.next)

    addSection = (section) ->
      section.pages = []
      section.getname = getname
      if data.length
        section.previous = data[data.length - 1]
        section.previous.next = section
      section.addPage = (page)->
        page.active = false
        page.section = this
        page.id = section.id + '.' + this.pages.length

        page.previous = findPreviousPageBeforeInsertion(section)
        if page.previous
          if page.previous.next
            page.previous.next.previous = page
          page.previous.next = page

        page.next = findNextPageBeforeInsertion(section)
        if page.next
          if page.next.previous
            page.next.previous.next = page
          page.next.previous = page

# maybe we should have chosen between javascript arrays and a couple of linked list to represent our data, instead of doing both :)
        page.destroy = ()->
          if page.next
            page.next.previous = page.previous
          if page.previous
            page.previous.next = page.next
          page.section.pages.splice(page.index,1)

        page.index = this.pages.push page  

      section.destroy = ()->
        if section.next
          section.next.previous = section.previous
        if section.previous
          section.previous.next = section.next
        data.splice(section.index, 1)
        

      section.index = data.push(section)
      


    sections = { 
      finalCount: -1
      count : 0
      data
      onLoad : (funcPerSection, onEnd) ->
        if nbrOfSectionsToLoad == nbrOfSectionsLoaded
          execute funcPerSection
          if onEnd then onEnd()
          return
        delayedOnLoad.push {perSection:funcPerSection, onEnd:onEnd}      
        return
      addSection
      nbrOfSectionsToLoad: (nbr) ->            
        nbrOfSectionsToLoad = nbr
        nbrOfSectionsLoaded = 0        
      loadedOneSection : ()->
        nbrOfSectionsLoaded++
        if nbrOfSectionsLoaded == nbrOfSectionsToLoad          
          for funcPairs in delayedOnLoad
            execute funcPairs.perSection
            if funcPairs.onEnd then funcPairs.onEnd()      
          return      
      isLoaded: ()->
        nbrOfSectionsToLoad == nbrOfSectionsLoaded
    }
    
    getname = () ->
      return this.name if typeof this.name == "string"
      return this.name[Locale.get().language]
    
        
    loadSectionsCsonFile = ()->
        loaded = true         
      
    return sections
  ]  
  
module.exports = 'sections'