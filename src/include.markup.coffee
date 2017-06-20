module.exports = 'includeMarkup'
require('angular').module('includeMarkup', ['config', require('./marked.config'), require('angular-marked'),require('./quirks'), require('./mobile.expand'), require('./language.picker')])

  .factory('ReadDataFile',['$http' , ($http ) ->
    
    
    files = {}
    
    
    loadDataFile = (filename, dataObject) -> 
      $http.get('/data/' + filename).then (response) ->
        files[filename] = response.data
        dataObject.data = response.data
        return
      ,(response) -> console.log 'Could not load '+filename+' : ' + JSON.stringify(response)
        
      
    
    return (filename, dataObject) ->
      if !files[filename]
        loadDataFile(filename, dataObject)
      else
        dataObject.data = files[filename]        
      return
    
  ])
  .directive('includeMarkup', [ 'ReadDataFile','marked', 'Quirks','MobileExpand', 'State', 'Locale', (ReadDataFile,marked, Quirks, MobileExpand, State, Locale )->
      restrict: 'E',
      template: '<span class="include-markup" ng-style="{\'display\':(content.inline && !isExpanded())?\'inline\':\'block\', \'width\': (content.inline?\'auto\':\'100%\')}">'+
              '<span class="include-markup-chapeau" ng-style="{\'display\':(content.inline)?\'inline-block\':\'block\'}" ng-if="chapeau" marked="chapeau" compile="true" popup-links="popupLinks"></span> ' +
              '<span ng-style="{\'display\':(content.inline?\'inline\':\'inline-block\'), \'width\': (content.inline?\'auto\':\'100%\'), \'text-align\':(content.inline?\'inherit\':\'center\')}">'+
              '<button ng-show="!defaultExpanded() || !content.data" ng-click="toogleExpand(content)" class="toggle-expand" ng-class="{\'inline\':content.inline}" > '+
#              '<span  ng-show="!content.expanded">  {{content.caption || "En Savoir Plus"}} </span>'+
              '<span  ng-show="isExpanded() && !content.data"><i class="fa fa-spinner fa-pulse"></i>'+
              '<span class="sr-only" >Loading...</span></span>' +
#              '<span  ng-show="content.expanded && content.data">  {{content.collapse || "Masquer"}} </span>'+
              '<i class="fa" ng-class=\'{"fa-minus":content.expanded && content.data, "fa-plus":!isExpanded()}\' ></i></button></span>'+             
              '<span ng-if="!isMobileLayout()" class="more" ng-show="isExpanded() && content.data" marked="content.data.replace(chapeau,\'\')" compile="true" popup-links="popupLinks"></span> </span>' 
      scope: {content: '=', popupLinks: '='},
      replace: true, 
      link: (scope,elt,attrs) ->
        #filename that end with .md should not be localised, we want the very file specified
        #othewise, add '.[locale].md' at the end
        localizeFilename = (filename) ->
          if filename.substr(-4) == '.md'
            return filename
          return filename + '.' + Locale.get().language + '.md'
        
        localizeChapeau = (chapeau) ->
          if typeof chapeau == "object"
            return chapeau[Locale.get().language]
          else return chapeau
        
        scope.chapeau = localizeChapeau scope.content.chapeau  
          
        #make function accessible through scope:  
        scope.isMobileLayout = Quirks.isMobileLayout              
        scope.isExpanded = (()-> return scope.content.expanded || scope.defaultExpanded()) 
        scope.toogleExpand = (content) ->
          #this is not just a shortcut, wouldn't mesh well (opening two modals etc), so disable expansion if already expanded by default
          if scope.defaultExpanded() then return
          if !content.expanded #load content if necessary, and expand
            #filename for the included file actually depends on locale, so compute it here:
            filename = localizeFilename content.filename
            ReadDataFile(filename, content)  if !content.data
            content.expanded = true
            #for mobiles extanding the page itself is not an option, it causes all sort of layout problems,
            #so we open a modal window:
            if Quirks.isMobileLayout()
              onclose = (()->content.expanded = false;return)
              MobileExpand.open(content, scope.popupLinks).then(onclose,onclose)
          else
            content.expanded = false
          return     
          
        #listen to locale changing, and reload when it happens
        Locale.onChange(
          ()->
            locFilename = localizeFilename(scope.content.filename)
            if scope.content.data  && (scope.content.filename != locFilename) #localized content, reload
              scope.content.data = null
              if scope.isExpanded()
                ReadDataFile(localizeFilename(scope.content.filename), scope.content)
            scope.chapeau = localizeChapeau scope.content.chapeau, 
          scope
        )  
          
        #if we are displaying a displaying a single section, and the content is marked as "main" read the data right away to be able to display.
        
        scope.defaultExpanded = () ->
          return State.singleSection() && scope.content.main
          
        if scope.defaultExpanded()
          #filename for the included file actually depends on locale, so compute it here:
          filename = localizeFilename scope.content.filename
          ReadDataFile(filename, scope.content)          
          if Quirks.isMobileLayout()
            onclose = (()->State.home();return)
            MobileExpand.open(scope.content, scope.popupLinks).then(onclose,onclose)
        
        
  ])

