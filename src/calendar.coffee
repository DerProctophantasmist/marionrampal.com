module.exports = 'calendar'

moment = require 'moment'
require 'moment/locale/fr'
require 'moment-timezone' 
p= require 'bluebird'

require('angular').module('calendar', ['config', require('angular-marked'), require('angular-utils-pagination'), require('./language.picker'),  require('./states'),])
  .factory('Calendars',['Config', '$http' , 'Locale' , 'State', (Config, $http, Locale, State ) ->
    key = Config.googleApiKey
    
    
    calendars = {}
    moment.locale(Locale.get().language)
    errCount = 0
    
    
    setLocalTime = (event) ->
      if !event.start.dateTime
          event.localTime = moment(event.start.date).format("l")
      else if event.start.timeZone != undefined 
        event.localTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll") 
      else 
        event.localTime = moment(event.start.dateTime).format("lll")
     
    loadCalendar = (calId) -> 
      listEvents = 'https://www.googleapis.com/calendar/v3/calendars/' + calId + 
        '/events?key=' + key + '&timeMin=' + encodeURIComponent(moment().format()) + '&singleEvents=true&orderBy=startTime&fields=items(htmlLink,summary,location,description,start(date,dateTime,timeZone))'
      return calendars[calId] = $http.get(listEvents)
        .then( (response) ->          
          calendar = []
          for event in response.data.items
            setLocalTime(event)
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
          setLocalTime event
          
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
      template: '<ul class="calendar"><li dir-paginate="event in $c.calendar |itemsPerPage: 5" class="calendar-event">' +
              '<button ng-click="$c.toogleExpand(event)" ng-show="event.description" class="toggle-expand fa-stack fa-sm"> <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class=\'{"fa-minus":event.expanded, "fa-plus":!event.expanded}\' ></i></button>'+     
              '<span class="localTime">{{event.localTime}}</span>' +
              '<span class="summary">{{event.summary}}</span>' +       
              '<a target="blank" ng-href="{{$c.googleMaps(event)}}" class="location">{{event.location}}</a>' +
              '<div class="description" ng-show="event.expanded" marked="event.description"></div>' +
              '</li><dir-pagination-controls></dir-pagination-controls></ul>',
      bindings: {id: '@', emptyEvent: '@'},
      controller: ['Calendars', '$scope', (Calendars, $scope) ->
      
          this.calendar = []
          
          this.toogleExpand = (event) ->
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
            return
          return
        ]
      ,
      controllerAs: '$c'
  })

