module.exports = 'infoconcert'

moment = require 'moment'
# require 'moment/locale/fr'
# require 'moment-timezone' 
# striptags = require('striptags')


# getZoneFromOffset = (offsetString) -> moment.tz.names().find((tz) -> moment.tz(tz).format('Z') == offsetString)

require('angular').module('infoconcert', ['config', require('./language.picker'), ])
  .factory('Infoconcert',['Config', '$http' , 'Locale' , '$q', (Config, $http, Locale, $q) ->
    calendars = {}
    errCount = 0
    baseUrl = "https://www.infoconcert.com"

    parseInfoconcertPage = (response) ->
      parser = new DOMParser()
      concerts = []
      doc = parser.parseFromString(response.data, 'text/html')
      doc.querySelectorAll('.date-line-concert').forEach (curElement)->
        dateTime = curElement.querySelector("time").getAttribute("datetime")
        venue = curElement.querySelector('div.salle span[itemprop="name"]').innerText
        location = curElement.querySelector('div.ville-dpt');
        locality = location.querySelector('a>span[itemprop="locality"]').innerText
        if ticket = curElement.querySelector('a.btn_reservez')
          ticket = ticket.getAttribute('href')
          if ticket[0] == '/'
            ticket = "#{baseUrl}#{ticket}"

        concerts.push {venue:venue, location: {searchName: "#{venue}, #{location.innerText}",locality: locality, displayName:venue},  start: {dateTime: dateTime}, ticketUrl: ticket } 
      concerts
    
     
    noop = 
      then:(callback)->
        console.log "calendar not configured for infoconcert"
        callback([])
    
    setLocalDateTime = (event) ->
      if !event.start.dateTime
          event.localDateTime = moment(event.start.date).format("l")
      else if event.start.timeZone != undefined 
        event.localDateTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll") 
      else 
        event.localDateTime = moment(event.start.dateTime).format("lll")

    
    
     
    loadCalendar = (id) ->
      mainUrl = "#{baseUrl}/artiste/#{id}/concerts.html"    
      return calendars[id] = $http.get(mainUrl)
        .then( (response) ->  
          events = parseInfoconcertPage response
          console.log "Infoconcert events:"
          console.log events
          return events
        )
        .catch( (response) -> 
          console.log 'infoconcert request failed: ' + response.message + ', status: ' + response.status
          return [] if response.status == 404
          # we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if errCount++<3
            console.log "calendar error number " + errCount
            return [] 
          return []
        )
    
    
    Locale.onChange(()->
      moment.locale(Locale.get().language)
      for calId, calendar of calendars
        for event in calendar
          setLocalDateTime event          
    )

    return (calId) ->
      id = calId
      unless id?
        return noop        
      return calendars[id] ? loadCalendar(id)    
  ]) 