module.exports = 'calendar'

moment = require 'moment'
require 'moment/locale/fr'
require 'moment-timezone' 
{hyphensToCamelCase} = require('./utils')
striptags = require('striptags')
# FileSaver = require("file-saver")
calendarLink = require('calendar-link')

CSON = require('cson-parser')
require('angular-contenteditable')

setDateTimeFields = (event) ->
  if !event.start.dateTime
    return event.localDateTime = moment(event.start.date).format("ll")
  if event.start.timeZone?
    return event.localDateTime =  moment(event.start.dateTime).tz(event.start.timeZone).format("lll")      
  return event.localDateTime = moment(event.start.dateTime).format("lll")

addToGoogleCalendar = (event) ->
  if event.start.dateTime
    dates = moment(event.start.dateTime).format("YYYYMMDDTHHmmSS") + "/" + moment(event.end.dateTime ? event.start.dateTime).format("YYYYMMDDTHHmmSS")
  else  
    dates = moment(event.start.date).format("YYYYMMDD") + "/" + moment(event.start.date).add(1,'d').format("YYYYMMDD")
    
  googleEvent = {
    action:'TEMPLATE'
    text:event.summary
    dates
    ctz:event.timezone
    details:event.description
    location:event.location.searchName
  }

  params = Object.entries(googleEvent)
  .map(([key, val])->
      "#{encodeURIComponent(key)}=#{encodeURIComponent(val)}"
  )
  .join("&")  
  window.open('https://calendar.google.com/calendar/render?'+params)
  return
 

#a factory called on each event to create getters setters specific to this event:  
editEventFactory = (event)->
  event.editEvent = 
    sumnary: (newSummary)->
      event.summary = newSummary if arguments.length 
      console.log event
      return event.summary
  console.log event
  return


require('angular').module('calendar', ['config', require('angular-marked'), require('angular-utils-pagination'), require('./language.picker'),  require('./states'), require('./songkick'), require('./infoConcert'), require('./sendToServer'), 'contenteditable', require('./markdownArea'), require('./csvFile')])
  .factory('Calendars',['Config', '$http' , 'Locale' , 'State', (Config, $http, Locale, State ) ->

    calendars = {}
    _templates = {}
    moment.locale(Locale.get().language)
    errCount = 0
    
    loadCalendar = (calId) -> 
      $http({method: 'get', url: Config.dataPath + '/calendar-' +  calId + '.cson', headers: {'Cache-Control': 'no-cache'}})
        .then( (response) ->    
          {events,templates} =  CSON.parse(response.data)                    
          console.log events
          for event in events
            event.start.moment = moment(event.start.dateTime)
            if moment().isAfter(event.start.moment)
              event.notRecorded = true #old event, discard.
            setDateTimeFields(event)
            editEventFactory(event)
          _templates[calId] = templates
          return calendars[calId] = events
        )
        .catch( (response) -> 
          calendars[calId] = []
          _templates[calId] = {}
          console.log 'local calendar request failed: ' + response.message + ', status: ' + response.status
          # we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if errCount++<3
            console.log "calendar error number " + errCount
          return []
        )
    
    
    Locale.onChange(()->
      moment.locale(Locale.get().language)
      for calId, calendar of calendars
        for event in calendar
          setDateTimeFields event
          
    )
    
    return (calId) ->
      if arguments.length 
        if !calendars[calId]?
          return loadCalendar(calId)
        else
          return calendars[calId]
      else return { #if we call Calendar() with no argument, we return an extended interface
        templates:_templates
        calendars
      }

  ])
  .component('localCalendar', {
      template: """
              <ul class="calendar"><li ng-if="!$c.isEditMode()" dir-paginate="event in $c.calendar |itemsPerPage: $c.itemsPerPage" current-page="$c.currentPage" class="calendar-event"> 
              <button ng-click="$c.toogleExpand(event)"  class="toggle-expand fa-stack fa-sm"> 
                <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class='{"fa-minus":event.expanded, "fa-plus":!event.expanded}' ></i>
              </button>
              <span class="localTime">{{event.localDateTime}}</span> 
              <div class="summary">{{event.summary}}</div>
              <a target="blank" ng-href="{{$c.googleMaps(event.location.searchName)}}" class="location">
                {{event.location.displayName}}{{event.location.locality?', '+event.location.locality:''}}{{event.location.country?', '+event.location.country:''}}
              </a> 
              <div ng-show="event.expanded">
                <div class="description" marked="event.description"></div>
                <ng-show="event.ticketUrl!=''">tickets: <a target="blank" ng-href="{{event.ticketUrl}}">{{event.ticketUrl}}</a><br/></ng-show>
              </div>
              </li>             
              
              <li  ng-if="$c.isEditMode()" dir-paginate="event in $c.calendar |itemsPerPage: $c.itemsPerPage" current-page="$c.currentPage"  class="calendar-event"> 
                <button ng-click="$c.toogleExpand(event)"  class="toggle-expand fa-stack fa-sm"> 
                  <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class='{"fa-minus":event.expanded, "fa-plus":!event.expanded}' ></i>
                </button>
                <button ng-show="!event.notRecorded" ng-click="$c.deleteEvent(($c.currentPage-1)*$c.itemsPerPage+$index)"  class="edit-event btn btn-default"> 
                  delete event
                </button> 
                <span  class="localTime"  style="{{event.notRecorded?'color:red;':''}}">{{event.localDateTime}}</span>
                <span style="display:block;" contenteditable=true ng-model="event.summary"  class="summary" style="{{event.notRecorded?'color:red;':''}}"></span>
                <div  ng-init="$c.setupDateFields(event)" >
                  <input type="text" uib-datepicker-popup ng-model="event.start.dateTmp" ng-change="$c.dateChanged(event)" is-open="event.datePopup"  ng-click="event.datePopup=true" / >
                  <uib-timepicker ng-model="event.start.dateTmp" ng-change="$c.timeChanged(event)"  show-meridian="false" show-spinners="false" ></uib-timepicker>
                  <input type="checkbox" ng-checked="event.start.dateTime != null" ng-click="$c.toggleDateTime(event)" />                
                </div>
                <a contenteditable=true target="blank" ng-href="{{$c.googleMaps(event.location.searchName)}}" style="width:70%" class="location" ng-model="event.location.searchName"></a> 
                <button ng-click="$c.checkVenue(event.location)" ng-show="event.location"  class="fa-stack fa-sm clickable-icon"> 
                  <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse fa-search" ></i>
                </button>
                <span ng-show="$c.hasLocationDetails(event)">
                  <br /><span style="display:inline-block;" contenteditable=true ng-model="event.location.displayName" ></span> <br />
                  Adresse: <span style="display:inline-block;" contenteditable=true ng-model="event.location.address"></span><br ng-if="event.location.address"/>
                  ZIP: <span style="display:inline-block;" contenteditable=true ng-model="event.location.postalCode"></span><span ng-if="event.location.postalCode"> </span>
                  Commune: <span style="display:inline-block;" contenteditable=true ng-model="event.location.locality"></span><span ng-if="event.location.locality">, </span>
                  Pays: <span style="display:inline-block;" contenteditable=true ng-model="event.location.country"></span> 
                </span>
                <div  ng-show="event.expanded" style="width:100%; position: relative"> 
                  tickets: <a contenteditable=true target="blank" ng-href="{{event.ticketUrl}}" style="width:70%; display:inline-block; background-color:white;" ng-model="event.ticketUrl"></a><br/>
                  <select class="small" ng-model="event.template" ng-options="template as name for (name,template) in $c.templates" ng-keydown="$c.keyPressTemplate(event,$event)" style="position: absolute; left: 70%;" ng-change="$c.applyTemplate(event)"></select>
                  band: <input type="text" ng-model="event.band"  style="width:50%; display:inline-block; background-color:white;"></input><br/>
                  lineup: <button ng-click="addPerformer()" class="btn btn-default">Add performer</button><br/>
                  <div ng-repeat="performer in event.lineup">
                    <input type="text" ng-model="performer.name"  style="width:30%; display:inline-block; background-color:white;"></input>                  
                    <input type="text" ng-model="performer.instrument"  style="width:30%; display:inline-block; background-color:white;"></input>
                    <button ng-click="removePerformer($index)" class="btn btn-default">Remove</button> 
                  </div>
                  <markdown-area  field-value="event.description" on-update="event.description=value"></markdown-area>
                  <button  ng-click="$c.saveAsTemplate(event)"  class="btn btn-default"> 
                    {{$c.textOfSaveAsTemplateButton}}
                  </button>
                </div>
              </li>
              <dir-pagination-controls></dir-pagination-controls>
              <button ng-if="$c.isEditMode()" ng-click="$c.saveCalendar()"  class="btn btn-default"> 
                {{$c.textOfSaveButton}}
              </button>
              <button ng-if="$c.isEditMode()" ng-click="$c.newEvent()"  class="edit-event btn btn-default"> 
                New event
              </button>
              <button ng-if="$c.isEditMode()" ng-click="$c.export()"  class="btn btn-default"> 
                {{$c.textOfExportButton}}
              </button>
              </ul>               
              """,
      bindings: {id: '@', emptyEvent: '@', musicBrainzId:'@', songkickId: '@', infoconcertId: '@'}
      controller: ['Config', 'Calendars', '$scope',  'Songkick',  'Infoconcert','$http', 'State', 'SendToServer', 'CsvFile', (Config, Calendars, $scope, Songkick, Infoconcert, $http, State, SendToServer, CsvFile) ->
      
          this.itemsPerPage = 5
          this.currentPage = 1  
          this.isEditMode = ()=> State.getAllowEdit()

          this.deleteEvent=(index)=>
            this.calendar.splice(index, 1)
            return
          
          this.calendar = []
          this.templates = {}
          this.events = {} #used only in staging mode to add events frem external sources (Songkick…)

          this.newEvent=()=>
            n = 
              start: {dateTime :new Date().toString()}
              notRecorded: true
              location:{}
            setDateTimeFields(n)
            this.calendar.splice(Math.min(@calendar.length,@currentPage*@itemsPerPage-1), 0, n)  

          this.applyTemplate=(event)=>
            event.description = event.template.description
            event.band = event.template.name
            event.linup = event.template.lineup
            if !event.summary || event.summary == "<br>"
              event.summary = "#{event.template.name} à #{event.location.locality}"

          this.addPerformer=()=>
            this.event.lineup.push({name: "", instrument: ""})
          
          this.removePerformer=(index)=>
            this.event.lineup.splice(index, 1)

          this.textOfSaveButton = "Save Calendar"
          this.textOfSaveAsTemplateButton = "Save as template"
          this.textOfExportButton = "Export"

          this.setupDateFields = (event)=>
            event.start.dateTmp =  new Date(if event.start.dateTime? then event.start.dateTime else event.start.date)
          
          this.toggleDateTime=(event)=>
            if event.start.dateTime
              event.start.date = moment(event.start.dateTime).startOf('day')
              event.start.dateTime = null
              event.start.dateTmp = new Date(event.start.date)
            else
              event.start.dateTime = event.start.date
              event.start.dateTmp = new Date(event.start.date)
            setDateTimeFields(event)
          

          this.timeChanged=(event)=>
            event.start.dateTime = event.start.dateTmp.toString()
            setDateTimeFields(event)

          this.dateChanged=(event)=>
            if event.start.dateTime?
              event.start.dateTime = event.start.dateTmp.toString()
            else
              event.start.date = event.start.toDateString()
            setDateTimeFields(event)

          
          this.saveCalendar = (name, curContent)=>        
            deleteBrs = (o)=>
              for key, val of o
                switch typeof val
                  when "object"
                    if val!= null then deleteBrs(val)  
                  when "string"
                    if val.slice(-4) == "<br>"  
                      o[key] = val.slice(0,-4)  
              o

            # todo: order calendar by date before saving
            SendToServer.textFile("calendar-#{this.id}.cson",CSON.stringify(
              {
                events: this.calendar.reduce(
                  (savedEvents, event)=>
                    return savedEvents if event.notRecorded # we don't want to save this one, don't change the accumulator

                    event.start.moment = moment(event.start.dateTime)
                    if moment().isAfter(event.start.moment)
                      return savedEvents #old event, discard.
                    n = savedEvents.length
                    
                    # find were to insert the new event:
                    findOlder = (i, savedEvents, event) ->
                      if i == 0
                        return 0
                      if event.start.moment.isAfter(savedEvents[i-1].start.dateTime)
                        return i
                      return findOlder(i-1, savedEvents, event)

                    n = findOlder(n, savedEvents, event)

                    # insert the new event in savedEvents at position n:
                    savedEvents.splice(n,0, deleteBrs
                     title: event.title    
                     summary: event.summary         
                     description: event.description
                     band: event.band
                     location: { searchName: event.location.searchName, displayName: event.location.displayName, address: event.location.address, postalCode: event.location.postalCode, locality: event.location.locality, country: event.location.country }
                     start: event.start 
                     ticketUrl: event.ticketUrl                  
                    )
                    return savedEvents
                  , []
                  )
                templates: this.templates
              }


            )).then( 
              (response)=>
                console.log "saved calendar"
                this.textOfSaveButton = "Saved"
                setTimeout((()=>this.textOfSaveButton = "Save Calendar"), 1000)
            ) 
            .catch((error) => alert(error))
            

          this.updateEvent = (event, prop, value)=>
            event[prop] = value
            return

          this.addNewEvents = (newEvents) => 
            for newEvent in newEvents
              setDateTimeFields(newEvent)
              if (existing = this.events[newEvent.localDateTime])?
                if !existing.ticketUrl  && newEvent.ticketUrl?
                  existing.ticketUrl = newEvent.ticketUrl
                continue
              newEvent.notRecorded = true
              this.calendar.unshift(newEvent)
              this.events[newEvent.localDateTime] = newEvent

            return
    
          this.toogleExpand = (event) ->
            if event.notRecorded 
              event.notRecorded = false
            event.expanded = !event.expanded
            return    
 
          this.hasLocationDetails = (event) -> 
            loc = event.location
            return loc.displayName || loc.address || loc.postalCode || loc.locality || loc.country

          this.googleMaps = (name) ->
            #google maps links in calendar should only be active if event is expanded: Why the hell? activate all the time
#            if event.expanded
              return "https://www.google.com/maps/search/?api=1&query=" + encodeURIComponent(name)
#            return ""
          
          this.checkVenue = (location) =>
            $http.post('./googleapis/places/v1/places:searchText',{"textQuery":location.searchName},
              headers:
                'Content-Type':'application/json'
                'X-Goog-FieldMask':'places.displayName,places.addressComponents,places.formattedAddress'
            ).then (res)->
              if (places = res.data.places) && (places.length == 1)
                for component in places[0].addressComponents
                  location[hyphensToCamelCase(component.types[0])] = component.longText
                location.address = (if location.streetNumber? then (location.streetNumber + " ") else "" ) + if  location.route then location.route else ""
                location.displayName = places[0].displayName.text
            return

          this.saveAsTemplate = (event)=>
            this.templates[event.band] = {description: event.description, name: event.band, lineup: event.lineup}
            buttonText = this.textOfSaveAsTemplateButton
            this.textOfSaveAsTemplateButton = "Saved"
            setTimeout((()=>this.textOfSaveAsTemplateButton = buttonText), 1000)
            return

          this.keyPressTemplate = (event, keyPress)=>
            console.log "keyPress:"
            console.log {keyPress: keyPress, event: event}
            if keyPress.key == "Delete" || keyPress.key == "Backspace"
              delete this.templates[event.band]

          this.export = () =>
            bandsintownCsv = CsvFile("bandsintown.csv").then (csv)=>
              events = this.calendar.reduce(
                (exportedEvents, event)=>
                  return exportedEvents if event.notRecorded # we don't want to save this one, don't change the accumulator

                  exportedEvents.push({
                    venue: event.location.displayName
                    country: event.location.country
                    address: event.location.address
                    city: event.location.locality
                    region: event.location.region
                    "postal code": event.location.postalCode
                    "start date": moment(event.start.dateTime).format("YYYY-MM-DD")
                    "start time": moment(event.start.dateTime).format("HH:mm")
                    "ticket link": event.ticketUrl
                    # lineup: event.lineup 
                    "event name": event.summary
                    "event display format": "Event Name"
                    "description": event.description 
                  })
                  return exportedEvents
                , []
              )
              console.log events
              csv(events)
            songkickCsv = CsvFile("songkick.csv").then (csv)=>
              events = this.calendar.reduce(
                (exportedEvents, event)=>
                  return exportedEvents if event.notRecorded # we don't want to save this one, don't change the accumulator

                  exportedEvents.push({
                    venue: event.location.displayName
                    city:event.location.locality
                    "country or state": event.location.country
                    address: event.location.address
                    "date":moment(event.start.dateTime).format("YYYY-MM-DD"),
                    "time":moment(event.start.dateTime).format("hh:mm A") 
                    "ticket link": event.ticketUrl
                    "event name":event.summary
                    description: event.description
                  })
                  return exportedEvents
                , []                
              )
              console.log events
              csv(events) 
          

          this.$onInit = ()->
            Calendars(this.id).then (res)=>
              if !State.getAllowEdit() # out of edit mode, filter out events that should not be recorded (i.e. are past)
                res = res.filter (event)=>
                  return !event.notRecorded

              if res.length == 0
                $scope.$emit(this.emptyEvent)

              this.calendar = res
              this.templates = Calendars().templates[this.id]
              for name,template of this.templates
                template.name = name

              console.log "templates:"
              console.log this.templates

              if State.getAllowEdit()
                #events is a "copy" of this.calendar but indexed by localDateTime
                this.events = this.calendar.reduce((events,event)->
                  events[event.localDateTime] = event
                  return events
                ,{})            

                Promise.all([Songkick({musicBrainzId:this.musicBrainzId, songkickId: this.songkickId}),Infoconcert(this.infoconcertId)] ).then (values)=>
                  this.addNewEvents(values[0])
                  this.addNewEvents(values[1])
                  console.log "fetched new concerts:"
                  console.log values
                
              return
          return
        ]
      ,
      controllerAs: '$c'
  })



