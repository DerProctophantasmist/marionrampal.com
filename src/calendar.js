// Generated by CoffeeScript 2.6.1
(function() {
  var addToGoogleCalendar, calendarLink, moment, setLocalDateTime, striptags;

  module.exports = 'calendar';

  moment = require('moment');

  require('moment/locale/fr');

  require('moment-timezone');

  striptags = require('striptags');

  // FileSaver = require("file-saver")
  calendarLink = require('calendar-link');

  setLocalDateTime = function(event) {
    if (!event.start.dateTime) {
      return event.localDateTime = moment(event.start.date).format("ll");
    }
    if (event.start.timeZone != null) {
      return event.localDateTime = moment(event.start.dateTime).tz(event.start.timeZone).format("lll");
    }
    return event.localDateTime = moment(event.start.dateTime).format("lll");
  };

  addToGoogleCalendar = function(event) {
    var dates, googleEvent, params, ref;
    if (event.start.datetime) {
      dates = moment(event.start.datetime).format("YYYYMMDDTHHmmSS") + "/" + moment((ref = event.end.datetime) != null ? ref : event.start.datetime).format("YYYYMMDDTHHmmSS");
    } else {
      dates = moment(event.start.date).format("YYYYMMDD") + "/" + moment(event.start.date).add(1, 'd').format("YYYYMMDD");
    }
    googleEvent = {
      action: 'TEMPLATE',
      text: event.summary,
      dates,
      ctz: event.timezone,
      details: event.description,
      location: event.location
    };
    params = Object.entries(googleEvent).map(function([key, val]) {
      return `${encodeURIComponent(key)}=${encodeURIComponent(val)}`;
    }).join("&");
    window.open('https://calendar.google.com/calendar/render?' + params);
  };

  require('angular').module('calendar', ['config', require('angular-marked'), require('angular-utils-pagination'), require('./language.picker'), require('./states'), require('./songkick')]).factory('Calendars', [
    'Config',
    '$http',
    'Locale',
    'State',
    function(Config,
    $http,
    Locale,
    State) {
      var calendarId,
    calendars,
    errCount,
    key,
    loadCalendar;
      key = Config.googleApiKey;
      calendars = {};
      moment.locale(Locale.get().language);
      errCount = 0;
      loadCalendar = function(calId) {
        var listEvents;
        listEvents = 'https://www.googleapis.com/calendar/v3/calendars/' + calId + '/events?key=' + key + '&timeMin=' + encodeURIComponent(moment().format()) + '&singleEvents=true&orderBy=startTime&fields=items(htmlLink,summary,location,description,start(date,dateTime,timeZone))';
        return calendars[calId] = $http.get(listEvents).then(function(response) {
          var calendar,
    event,
    i,
    len,
    ref;
          calendar = [];
          ref = response.data.items;
          for (i = 0, len = ref.length; i < len; i++) {
            event = ref[i];
            setLocalDateTime(event);
            console.log(event.description);
            event.description = striptags(event.description,
    ['a',
    'u',
    'i',
    'b',
    'ol',
    'li console.log(ICalendar)',
    'ul'],
    '  \n');
            calendar.push(event);
          }
          console.log(response.data);
          return calendar;
        }).catch(function(response) {
          console.log('google calendar request failed: ' + response.message + ', status: ' + response.status);
          if (response.status === 404) {
            return [];
          }
          // we "eat" the error at some point, won't retry to access the calendar (note it is a global err count, not per calendar):
          if (errCount++ < 3) {
            console.log("calendar error number " + errCount);
            return null;
          }
          return [];
        });
      };
      Locale.onChange(function() {
        var calId,
    calendar,
    event,
    results;
        moment.locale(Locale.get().language);
        results = [];
        for (calId in calendars) {
          calendar = calendars[calId];
          results.push((function() {
            var i,
    len,
    results1;
            results1 = [];
            for (i = 0, len = calendar.length; i < len; i++) {
              event = calendar[i];
              results1.push(setLocalDateTime(event));
            }
            return results1;
          })());
        }
        return results;
      });
      
      //this is just preloading: the calendar id is also defined in the website section that displays it
      calendarId = Config.googleCalendar;
      loadCalendar(calendarId);
      return function(calId) {
        if (calendars[calId] == null) {
          return loadCalendar(calId);
        } else {
          return calendars[calId];
        }
      };
    }
  ]).component('googleCalendar', {
    template: `<ul class="calendar"><li dir-paginate="event in $c.calendar |itemsPerPage: 5" class="calendar-event"> 
<button ng-click="$c.toogleExpand(event)" ng-show="event.description" class="toggle-expand fa-stack fa-sm"> 
  <i class="fa fa-circle fa-stack-2x"></i> <i class="fa fa-stack-1x fa-inverse" ng-class='{"fa-minus":event.expanded, "fa-plus":!event.expanded}' ></i>
</button>
<span class="localTime">{{event.localDateTime}}</span> 
<span class="summary" style="{{event.notRecorded?'color:red;':''}}">{{event.summary}}</span>
<a target="blank" ng-href="{{$c.googleMaps(event)}}" class="location">{{event.location}}</a> 
<div class="description" ng-show="event.expanded" marked="event.description"></div> 
</li><dir-pagination-controls></dir-pagination-controls></ul>`,
    bindings: {
      id: '@',
      emptyEvent: '@',
      musicBrainzId: '@',
      songkickId: '@'
    },
    controller: [
      'Calendars',
      '$scope',
      'Songkick',
      '$http',
      'State',
      function(Calendars,
      $scope,
      Songkick,
      $http,
      State) {
        this.calendar = [];
        this.toogleExpand = function(event) {
          if (event.notRecorded) { //open in google calendar
            addToGoogleCalendar(event);
            return;
          }
          event.expanded = !event.expanded;
        };
        this.googleMaps = function(event) {
          //google maps links in calendar should only be active if event is expanded: Why the hell? activate all the time
          //            if event.expanded
          return "https://www.google.com/maps/search/?api=1&query=" + encodeURIComponent(event.location);
        };
        //            return ""
        this.$onInit = function() {
          return Calendars(this.id).then((res) => {
            var events;
            if ((res != null) && res.length === 0) {
              $scope.$emit(this.emptyEvent);
            }
            console.log(JSON.stringify("calendar: " + res));
            this.calendar = res;
            if (State.getAllowEdit()) {
              events = this.calendar.reduce(function(events,
      event) {
                events[event.localDateTime] = event;
                return events;
              },
      {});
              Songkick({
                musicBrainzId: this.musicBrainzId,
                songkickId: this.songkickId
              }).then((newEvents) => {
                var i,
      len,
      newEvent,
      results;
// calendar = ical({name:'Songkick events'})
// calendar.createEvent(newEvents[0])
// FileSaver.saveAs(calendar.toBlob(),'Songkick events')
                results = [];
                for (i = 0, len = newEvents.length; i < len; i++) {
                  newEvent = newEvents[i];
                  setLocalDateTime(newEvent);
                  if (events[newEvent.localDateTime] != null) {
                    continue;
                  }
                  newEvent.notRecorded = true;
                  results.push($http.get(`http://api.geonames.org/timezoneJSON?lat=${newEvent.lat}&lng=${newEvent.lng}&username=proctophantasmist`).then(((newEvent) => {
                    return (response) => {
                      newEvent.timezone = response.data.timezoneId;
                      return this.calendar.unshift(newEvent);
                    };
                  })(newEvent)).catch(function(error) {
                    console.log(error);
                    return console.log("could not retrieve timezone data from geonames");
                  }));
                }
                return results;
              });
            }
          });
        };
      }
    ],
    controllerAs: '$c'
  });

}).call(this);

//# sourceMappingURL=calendar.js.map
