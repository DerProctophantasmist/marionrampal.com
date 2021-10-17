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
     
    
    setLocalDateTime = (event) ->
      if !event.start.dateTime
          event.localDateTime = moment(event.start.date).format("l")
      else if event.start.timeZone != undefined 
        event.localDateTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll") 
      else 
        event.localDateTime = moment(event.start.dateTime).format("lll")
     
    loadCalendar = (musicBrainzId) -> 
      listEvents = 'https://api.songkick.com/api/3.0/artists/mbid:' + musicBrainzId + 
        '/calendar.json?apikey=' + key
      return calendars[musicBrainzId] = $http.get(listEvents)
        .then( (response) ->      
          events = response.data.resultsPage.results.event
          console.log events
          return events.map((event)->
            date = event.start.datetime
            # date = date.substring(0,date.length-5) + "+0100"
            offsetString =  date.substring(date.length-5)
            #offsetString is in the format +-hhmm, we need +-hh:mm
            offsetString = offsetString.slice(0,3) + ":" + offsetString.slice(3)
            return {
              summary: event.displayName
              location: "#{event.venue.displayName}, #{event.location.city}"
              description: event.uri
              start: date
              localDateTime : moment(date).format("lll")
              end: date
              lat: event.venue.lat
              lng: event.venue.lng
              # timezone:  getZoneFromOffset(offsetString)
            }            
          )
        )
        .catch( (response) -> 
          console.log 'songkick request failed: ' + response.message + ', status: ' + response.status
          return [] if response.status == 404
          # we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if errCount++<3
            console.log "calendar error number " + errCount
            return null 
          return []
        )
    
    
    Locale.onChange(()->
      moment.locale(Locale.get().language)
      for calId, calendar of calendars
        for event in calendar
          setLocalDateTime event          
    )

    return (calId) ->
      if !calendars[calId]?
        return loadCalendar(calId)
      else
        return calendars[calId]
    
  ]) 