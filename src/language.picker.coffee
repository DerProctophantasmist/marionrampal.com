
module.exports = 'languagePicker'
require('angular-bootstrap-locale-dialog');
EventEmitter = require('events');
#require('flag-icon-css')

picker = require('angular').module('languagePicker',  [
  'ui.bootstrap',
  'ui.bootstrap.locale-dialog',
  require('angular-cookies')
])
.factory('Locale', ['$window', '$cookies', ($window, $cookies)->
  defaultLoc = {
    "en": "en-US",
    "fr": "fr-FR"
  }
  availLoc = {
    "en-US": {
      "name": "English (US)",
      "language": "en",
      "country": "us"
    },
    "fr-FR": {
      "name": "Fran\u00e7ais (FR)",
      "language": "fr",
      "country": "fr"
    }
  }
  emitter = new EventEmitter();
  emitter.setMaxListeners(100000);
  
  if storedLocale =  $cookies.get('marionrampal.locale')
    console.log "stored locale: " + storedLocale
    curLocale =  availLoc[storedLocale]    
    if !curLocale
      $cookies.remove('marionrampal.locale')
  else console.log("no stored locale")
  
  return locale = {
    available: availLoc,
    set: (newLocale, persist=false, emit = true) ->
    
      if newLocale.length == 2
        newLocale = defaultLoc[newLocale]
      if availLoc[newLocale]?
        curLocale = availLoc[newLocale]
        emitter.emit('changeLocale') if emit
        if persist
          $cookies.put('marionrampal.locale', newLocale)        
          console.log("stored locale: " + newLocale)
  
      else if curLocale == null
        curLocale = availLoc['fr-FR']
        emitter.emit('changeLocale') if emit
      return curLocale
    ,
    get: () ->
      return curLocale
    ,
    name: () ->
      return if curLocale then curLocale.name 
      else 
        null
        console.log "locale was not set!"
    ,
    init: (prefLang, forceLang) ->   
      console.log "locale init, prefLang: " + prefLang + ", forceLang: " + forceLang
      if forceLang
        locale.set(forceLang,false, false)
      else if !storedLocale? 
        locale.set(prefLang, false, false) #if prefLang is not valid locale will be set to French by default
        
     
    onChange: (callback, scope)->      
      emitter.on('changeLocale',callback)         
      if scope
        scope.$on('$destroy', ()-> 
          emitter.removeListener('changeLocale',callback)
        )    
    offChange:(callback)->
      emitter.removeListener('changeLocale',callback)
    
  }
])
.controller('LangPickCtrl', ['$localeSelectorDialog','Locale',($localeSelectorDialog, Locale) ->
  vm = this;
  vm.selectedLocale = Locale.name()
  console.log(vm.selectedLocale)
  
  vm.classShowFlag = ()->
    return "flag-icon flag-icon-" +  Locale.get().country
 
  vm.changeLocale =  () ->
    $localeSelectorDialog.open({
      locales: Locale.available,
      showFlags: true,
      showSearch: false
    }).result.then( (selectedLocale) ->
      Locale.set(selectedLocale, true)
      vm.selectedLocale = Locale.name()
      return
    )
    return
  return
])

# we generate multiple directives in the form i18n-attrname/i18nAttrname:
# translations are passed to i18nAttrName in the form {fr:"French", en:"English"}, and then put into attrName
# I've commented out the code to watch for change of the i18nAttribute, we don't really need it
for name in ['Placeholder', 'Value'] 
  do (name) ->
    i18nAttrName = 'i18n' + name 
    attrName = name.substr(0,1).toLowerCase() + name.substr(1) #name of the "working" attribute into which we'll inject the translation
    picker.directive(i18nAttrName,['Locale', (Locale)->
#      scopeParam = {}
#      scopeParam[i18nAttrName] = '@'
      return  {   
        restrict: 'A',
#        scope: scopeParam,
        link: (scope, elt, attr) ->    

          attrValue = scope.$eval(attr[i18nAttrName])

          updatei18n = ()->
            elt.attr(attrName, attrValue[Locale.get().language])

          updatei18n()

          Locale.onChange(updatei18n, scope)

#          scope.$watch( i18nAttrName, (newValue, oldValue) -> 
#            attrValue = scope.$eval newValue
#            updatei18n()
#          )   
      }

    ])
  