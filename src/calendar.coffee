module.exports = 'calendar'

moment = require 'moment'
require 'moment/locale/fr'
require 'moment-timezone' 
striptags = require('striptags')
# FileSaver = require("file-saver")
calendarLink = require('calendar-link')

setLocalDateTime = (event) ->
  if !event.start.dateTime
    return event.localDateTime = moment(event.start.date).format("ll")
  if event.start.timeZone?
    return event.localDateTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll")      
  return event.localDateTime = moment(event.start.dateTime).format("lll")

addToGoogleCalendar = (event) ->
  if event.start.datetime
    dates = moment(event.start.datetime).format("YYYYMMDDTHHmmSS") + "/" + moment(event.end.datetime ? event.start.datetime).format("YYYYMMDDTHHmmSS")
  else  
    dates = moment(event.start.date).format("YYYYMMDD") + "/" + moment(event.start.date).add(1,'d').format("YYYYMMDD")
    
  googleEvent = {
    action:'TEMPLATE'
    text:event.summary
    dates
    ctz:event.timezone
    details:event.description
    location:event.location
  }

  params = Object.entries(googleEvent)
  .map(([key, val])->
      "#{encodeURIComponent(key)}=#{encodeURIComponent(val)}"
  )
  .join("&")  
  window.open('https://calendar.google.com/calendar/render?'+params)
  return
 

require('angular').module('calendar', ['config', require('angular-marked'), require('angular-utils-pagination'), require('./language.picker'),  require('./states'), require('./songkick')])
  .factory('Calendars',['Config', '$http' , 'Locale' , 'State', (Config, $http, Locale, State ) ->
    key = Config.googleApiKey
    
    
    calendars = {}
    moment.locale(Locale.get().language)
    errCount = 0
    
     
    loadCalendar = (calId) -> 
      listEvents = 'https://www.googleapis.com/calendar/v3/calendars/' + calId + 
        '/events?key=' + key + '&timeMin=' + encodeURIComponent(moment().format()) + '&singleEvents=true&orderBy=startTime&fields=items(htmlLink,summary,location,description,start(date,dateTime,timeZone))'
      return calendars[calId] = $http.get(listEvents)
        .then( (response) ->          
          calendar = []
          for event in response.data.items
            setLocalDateTime(event)
            console.log event.description
            event.description = striptags(event.description, ['a','u','i','b','ol','li
                console.log(ICalendar)','ul'],'  \n')
            calendar.push(event)
          console.log(response.data)
          return calendar
        )
        .catch( (response) -> 
          console.log 'google calendar request failed: ' + response.message + ', status: ' + response.status
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
    #this is just preloading: the calendar id is also defined in the website section that displays it
    calendarId = Config.googleCalendar
    loadCalendar(calendarId)
    
    return (calId) ->
      if !calendars[calId]?
        return loadCalendar(calId)
      else
        return calendars[calId]
    
  ]) 
  .component('googleCalendar', {
      template: """
              <ul class="calendar"><li dir-paginate="event in $c.calendar |itemsPerPage: 5" class="calendar-event"> 
              <button ng-click="$c.toogleExpand(event)" ng-show="event.description" class="toggle-expand fa-stack fa-sm"> 
                <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class='{"fa-minus":event.expanded, "fa-plus":!event.expanded}' ></i>
              </button>
              <span class="localTime">{{event.localDateTime}}</span> 
              <span class="summary" style="{{event.notRecorded?'color:red;':''}}">{{event.summary}}</span>
              <a target="blank" ng-href="{{$c.googleMaps(event)}}" class="location">{{event.location}}</a> 
              <div class="description" ng-show="event.expanded" marked="event.description"></div> 
              </li><dir-pagination-controls></dir-pagination-controls></ul>
              """,
      bindings: {id: '@', emptyEvent: '@', musicBrainzId:'@', songkickId: '@'},
      controller: ['Calendars', '$scope',  'Songkick', '$http', 'State', (Calendars, $scope, Songkick, $http, State) ->
      
          this.calendar = []
          
          this.toogleExpand = (event) ->
            if event.notRecorded #open in google calendar
              addToGoogleCalendar(event)
              return
            event.expanded = !event.expanded
            return          
          this.googleMaps = (event) ->
            #google maps links in calendar should only be active if event is expanded: Why the hell? activate all the time
#            if event.expanded
              return "https://www.google.com/maps/search/?api=1&query=" + encodeURIComponent(event.location)
#            return ""
          
          this.$onInit = ()->
            Calendars(this.id).then (res)=>
              if res? && res.length == 0
                $scope.$emit(this.emptyEvent)
              console.log JSON.stringify "calendar: "+ res
              this.calendar = res

              if State.getAllowEdit()
                events = this.calendar.reduce((events,event)->
                  events[event.localDateTime] = event
                  return events
                ,{})
                Songkick({musicBrainzId:this.musicBrainzId, songkickId: this.songkickId}).then (newEvents)=>
                  # calendar = ical({name:'Songkick events'})
                  # calendar.createEvent(newEvents[0])
                  # FileSaver.saveAs(calendar.toBlob(),'Songkick events')
                  for newEvent in newEvents
                    setLocalDateTime(newEvent)
                    if events[newEvent.localDateTime]?
                      return
                    newEvent.notRecorded = true
                    $http.get("http://api.geonames.org/timezoneJSON?lat=#{newEvent.lat}&lng=#{newEvent.lng}&username=proctophantasmist")
                    .then( ((newEvent) => 
                        (response) =>
                          newEvent.timezone=response.data.timezoneId
                          this.calendar.unshift(newEvent) 
                      )(newEvent)
                    )
                    .catch((error) ->
                      console.log error
                      console.log ("could not retrieve timezone data forme geonames")
                    )
              return
          return
        ]
      ,
      controllerAs: '$c'
  })

