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
    
    setLocalDateTime = (event) ->
      if !event.start.dateTime
          event.localDateTime = moment(event.start.date).format("l")
      else if event.start.timeZone != undefined 
        event.localDateTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll") 
      else 
        event.localDateTime = moment(event.start.dateTime).format("lll")
     
    loadCalendar = (id) ->
      listEvents = 'https://api.songkick.com/api/3.0/artists/' + id +  '/calendar.json?apikey=' + key
      return calendars[id] = $http.get(listEvents)
        .then( (response) ->      
          events = response.data.resultsPage.results.event
          console.log events
          return events.map((event)->
            event.start.dateTime = event.start.datetime
            if event.end?
              event.end.dateTime = event.end.datetime
            else event.end = event.start
            
            return {
              summary: event.displayName
              location: "#{event.venue.displayName}, #{event.location.city}"
              description: event.uri
              start: event.start
              end: event.end
              lat: event.venue.lat
              lng: event.venue.lng
              # timezone:  getZoneFromOffset(offsetString)
            }            
          )
        )
        .catch( (response) -> 
          console.log 'songkick request failed: ' + response.message + ', status: ' + response.status
          return noop if response.status == 404
          # we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if errCount++<3
            console.log "calendar error number " + errCount
            return noop 
          return noop
        )
    
    
    Locale.onChange(()->
      moment.locale(Locale.get().language)
      for calId, calendar of calendars
        for event in calendar
          setLocalDateTime event          
    )

    return (calId) ->
      if !Config.songkickApikey 
        return noop
      id = calId.songkickId ? (if calId.musicBrainzId? then "mbid:" + calId.musicBrainzId else null)
      unless id?
        return noop        
      return calendars[id] ? loadCalendar(id)    
  ]) 