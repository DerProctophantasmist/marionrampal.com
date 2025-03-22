module.exports = 'songkick'

moment = require 'moment'
# require 'moment/locale/fr'
# require 'moment-timezone' 
# striptags = require('striptags')


# getZoneFromOffset = (offsetString) -> moment.tz.names().find((tz) -> moment.tz(tz).format('Z') == offsetString)

require('angular').module('songkick', ['config', require('./language.picker'), ])
  .factory('Songkick',['Config', '$http' , 'Locale' , (Config, $http, Locale) ->
    key = Config.songkickApikey
    
    
    calendars = {}
    errCount = 0
     
    noop = 
      then:(callback)->
        console.log "calendar not configured for songkick"
        callback([])
    
    loadCalendar = (id) ->
      listEvents = 'https://api.songkick.com/api/3.0/artists/' + id +  '/calendar.json?apikey=' + key
      return calendars[id] = $http.get(listEvents)
        .then( (response) ->      
          events = response.data.resultsPage.results.event
          console.log "Songkick events:"
          console.log events
          return events.map((event)->
            event.start.dateTime = event.start.datetime
            if event.end?
              event.end.dateTime = event.end.datetime
            else event.end = event.start
            
            return {
              summary: event.displayName
              location: 
                searchName: "#{event.venue.displayName}, #{event.location.city}"
                displayName: event.venue.displayName
                locality: event.venue.city.displayName if event.venue.city?
                country:event.venue.city.country if event.venue.city?
                postalCode:event.location.zip
                address: event.location.street                
              description: event.uri
              start: { dateTime: event.start.datetime, date: event.start.date if !event.start.datetime?}
              end: { dateTime: event.end.datetime, date: event.end.date if !event.end.datetime?} if event.end?
            }            
          )
        )
        .catch( (response) -> 
          console.log 'songkick request failed: ' + response.message + ', status: ' + response.status
          return [] if response.status == 404
          # we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if errCount++<3
            console.log "calendar error number " + errCount
            return [] 
          return []
        )
    
    

    return (calId) ->
      if !Config.songkickApikey 
        return noop
      id = calId.songkickId ? (if calId.musicBrainzId? then "mbid:" + calId.musicBrainzId else null)
      unless id?
        return noop        
      return calendars[id] ? loadCalendar(id)    
  ]) 