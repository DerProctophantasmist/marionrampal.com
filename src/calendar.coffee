module.exports = 'calendar'

moment = require 'moment'
require 'moment/locale/fr'
require 'moment-timezone' 

require('angular').module('calendar', ['config', require('angular-marked'), require('angular-utils-pagination'), require('./language.picker')])
  .factory('Calendars',['Config', '$http' , 'Locale' , (Config, $http, Locale ) ->
    key = Config.googleApiKey
    
    
    calendars = {}
    moment.locale(Locale.get().language)
    
    
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
      $http.get(listEvents).then (response) ->
          for event in response.data.items
            setLocalTime(event)
            calendars[calId].push(event)
          console.log(response.data)
          return
        ,(response) -> console.log 'google calendar request failed: ' + JSON.stringify(response)
        
    
    
    Locale.onChange(()->
      moment.locale(Locale.get().language)
      for calId, calendar of calendars
        for event in calendar
          setLocalTime event
          
    )  
    #this is just preloading: the calendar id is also defined in the website section that displays it
    calendarId = Config.googleCalendar
    calendars[calendarId] = [];
    loadCalendar(calendarId)
    
    return (calId) ->
      if calendars[calId] == null
        calendars[calId]=[]
        loadCalendar(calId)
      return calendars[calId]
    
  ])
  .directive('googleCalendar', ['Calendars', 'marked', (Calendars, marked)->
      restrict: 'E',
      template: '<ul class="calendar"><li dir-paginate="event in calendars(id)|itemsPerPage: 5" class="calendar-event">' +
              '<button ng-click="toogleExpand(event)" ng-show="event.description" class="toggle-expand fa-stack fa-sm"> <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class=\'{"fa-chevron-down":event.expanded, "fa-chevron-up":!event.expanded}\' ></i></button>'+     
              '<span class="localTime">{{event.localTime}}</span>' +
              '<span class="summary">{{event.summary}}</span>' +       
              '<div class="location">{{event.location}}</div>' +
              '<div class="description" ng-show="event.expanded" marked="event.description"></div>' +
              '</li><dir-pagination-controls></dir-pagination-controls></ul>',
      scope: {id: '@'},
      replace: true, 
      link: (scope,elt,attrs) ->
        scope.calendars = Calendars
        scope.marked = marked
        scope.toogleExpand = (event) ->
          event.expanded = !event.expanded
          return     
        
  ])

