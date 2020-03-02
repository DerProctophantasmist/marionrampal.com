
CSON = require 'cson-parser'

require('angular').module('data.provider',[require('./language.picker'), require('./config')])
  .factory 'Sections',['$http', 'Locale', 'Config'
  , ($http, Locale, Config) -> 
    loaded = false
    delayedOnLoad = []
    onDone = null
    
    execute = (func) ->
      for section in sections.data
        func section
      return
      
    sections = { 
      data : []
      onLoad : (funcPerSection, onEnd) ->
        if loaded
          execute funcPerSection
          if onEnd then onEnd()
          return
        delayedOnLoad.push {perSection:funcPerSection, onEnd:onEnd}      
        return
        
    }
    
    getname = () ->
      return this.name if typeof this.name == "string"
      return this.name[Locale.get().language]
    
        
    
    $http.defaults.headers.common['Cache-Control'] = 'no-cache'
    $http({method: 'get', url: Config.dataPath + '/sections.cson'}).then (response) ->
#      sections.data = response.data
      sections.data = CSON.parse(response.data)
      for section, s in sections.data
        section.getname = getname
        section.previous = if s > 0 then sections.data[s-1] else null
        section.next = if s < sections.data.length - 1 then sections.data[s + 1] else null
        for page, p in section.pages
          page.active = false
          page.section = section
          page.id = section.id + '.' + p 
          if p > 0  
            page.previous = section.pages[p - 1] 
          else 
            if s > 0 
              previousSec = sections.data[s-1]
              page.previous = previousSec.pages[previousSec.pages.length - 1]
            else
              page.previous = null
          if p < section.pages.length - 1 
            page.next = section.pages[p + 1] 
          else 
            if s < sections.data.length - 1
              nextSec = sections.data[s+1]
              page.next = nextSec.pages[0]
            else
              page.next = null                
      loaded = true         
      for funcPairs in delayedOnLoad
        execute funcPairs.perSection
        if funcPairs.onEnd then funcPairs.onEnd()      
      return
    ,(response) -> console.log 'sections data request failed: ' + response.toString
    
    return sections
  ]  
  
module.exports = 'data.provider'