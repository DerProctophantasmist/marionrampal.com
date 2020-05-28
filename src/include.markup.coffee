module.exports = 'includeMarkup'
includeMarkupCtrl = [ 
  'DataFile','marked', 'Quirks','MobileExpand', 'State', 'Locale', '$scope', '$element', 
  (DataFile,marked, Quirks, MobileExpand, State, Locale, $scope,$element )->
    #for now we treat 404 and empty content the same way (loading spinner  ) so we just set content.data
    # to '' straight away, we could distinguish cases by handling content.data === null instead of just !content.data in the template
    # $scope.content.data = null 
    #filename that end with .md should not be localised, we want the very file specified
    #othewise, add '.[locale].md' at the end
    localizeFilename = (filename) ->
      if filename.substr(-3) != '.md'
        filename = filename + '.' + Locale.get().language + '.md'
      #we store it on the content so that the markdown editor button can correctly display the name of the file, doing it guarantees that it is always "up to date"
      $scope.content.localizedFilename = filename
      return filename


    localizeChapeau = (chapeau) ->
      if typeof chapeau == "object"
        return chapeau[Locale.get().language]
      else return chapeau

    #these are the callbacks functions for the editor, they are actually passed to the editor from the modal template
    onEdit = (markdown) ->
      #console.log("Markdown Editor change:\n" + markdown)
      $scope.content.data=markdown 
      expandedModal.refresh() if expandedModal #this just calls $apply() so that the watcher takes effect


    onSuccess = (markdown) ->
      $scope.content.data= markdown

    onClosedEditor = () ->
      console.log("Markdown Editor closed:\n" )

    expandedModal = null

    fileCallbacks =  
      onChange:onEdit
      on404:onSuccess
      onSuccess: onSuccess
      onError: ()->{} 
      


    $scope.chapeau = localizeChapeau $scope.content.chapeau  


    #handling preloaded content from the server:
    if $element.preload
      console.log 'include markup set preloaded:'
      console.log $element.preload
      DataFile.cache(localizeFilename($scope.content.filename),fileCallbacks, $scope,$element.preload)
      
    
    # $scope.content.data =  ""
    #make function accessible through $scope:  
    $scope.isMobileLayout = Quirks.isMobileLayout          
    # this would be for the editor (should we show it), not used here currently, since we do it in the modal:
    # $scope.globalState = State    
    $scope.isExpanded = (()-> return $scope.content.expanded || $scope.defaultExpanded()) 
    $scope.toogleExpand = (content) ->
      #this is not just a shortcut, wouldn't mesh well (opening two modals etc), so disable expansion if already expanded by default
      if $scope.defaultExpanded() then return
      if !content.expanded #load content if necessary, and expand
        #filename for the included file actually depends on locale, so compute it here:
        filename = localizeFilename content.filename # this actually sets  content.localizedFilename
        DataFile.read(filename,fileCallbacks, $scope)  if !content.data
        content.expanded = true
        #for mobiles extanding the page itself is not an option, it causes all sort of layout problems,
        #so we open a modal window:
        # if Quirks.isMobileLayout() 
        if MobileExpand.isOpen() # modal is open, and we clicked to expand, so we are in the modal
        # the goal is to just display the expanded content in place, for mobile and desktop both
          $scope.expandInPlace = true # no sync pbm with MobileExpand.isOpen(): the dom element is not going to get out of the modal by itself

        else #if !$scope.defaultExpanded()
          onclose = ()->
            content.expanded = false;
            expandedModal = null
            return
          MobileExpand.open(content, $scope.popupLinks).then(onclose,onclose)
          expandedModal = MobileExpand
      else
        content.expanded = false
      return 

      
    #listen to locale changing, and reload when it happens
    Locale.onChange(
      ()->
        locFilename = localizeFilename($scope.content.filename)
        if $scope.content.data  && ($scope.content.filename != locFilename) #localized content, reload
          $scope.content.data = null
          if $scope.isExpanded()
            DataFile.read(localizeFilename($scope.content.filename), fileCallbacks, $scope)
        $scope.chapeau = localizeChapeau $scope.content.chapeau, 
      $scope
    )  
      
    #if we are displaying a displaying a single section, and the content is marked as "main" read the data right away to be able to display.

    $scope.defaultExpanded = () ->
      return State.singleSection() # && $scope.content.main
      
    if $scope.defaultExpanded()
      #filename for the included file actually depends on locale, so compute it here:
      filename = localizeFilename $scope.content.filename
      DataFile.read(filename, fileCallbacks, $scope)          
      # if Quirks.isMobileLayout()
      #   onclose = (()->State.home();return)
      #   MobileExpand.open($scope.content, $scope.popupLinks).then(onclose,onclose)
]


template = '<span class="include-markup" ng-style="{\'position\':\'relative\', \'display\':(content.inline && !isExpanded())?\'inline-block\':\'block\', \'width\': (content.inline?\'auto\':\'100%\')}">'+
        '<span class="include-markup-chapeau" style="display:block" ng-if="chapeau && !content.inline" marked="chapeau" compile="true" popup-links="popupLinks"></span> ' +
        '<span class="clickable" ng-click="toogleExpand(content)" ng-style="{\'display\':(content.inline?\'inline\':\'inline-block\'), \'width\': (content.inline?\'auto\':\'100%\'), \'text-align\':(content.inline?\'inherit\':\'center\')}">'+
        '<span class="include-markup-chapeau" style="display:inline-block" ng-if="chapeau && content.inline" marked="chapeau" compile="true" popup-links="popupLinks"></span> ' +
        '<button ng-show="!defaultExpanded() || !content.data" class="toggle-expand" ng-class="{\'inline\':content.inline}" > '+
#       '<span  ng-show="!content.expanded">  {{content.caption || "En Savoir Plus"}} </span>'+
        '<span  ng-show="isExpanded() && !content.data"><i class="fa fa-spinner fa-pulse"></i>'+
        '<span class="sr-only" >Loading...</span></span>' +
#       '<span  ng-show="content.expanded && content.data">  {{content.collapse || "Masquer"}} </span>'+
        '<i class="fa" ng-class=\'{"fa-minus":content.expanded && content.data, "fa-plus":!isExpanded()}\' ></i></button></span>'+             
        '<span ng-if="defaultExpanded() || expandInPlace && content.expanded" class="more" ng-show="content.data" marked="content.data.replace(chapeau,\'\')" compile="true" popup-links="popupLinks"></span>' +
        '</span>' 

require('angular').module('includeMarkup', [
    require('./config'), require('./marked.config'), require('angular-marked'),require('./quirks'), require('./mobile.expand'), require('./language.picker'),
    require('./dataFile')
  ])
  .directive('includeMarkup', ['$compile', ($compile)->
    restrict: 'E'
    scope: {content: '<', popupLinks: '='}
    controller: includeMarkupCtrl
    link:  (scope, element, attrs)  ->
      #handling preloaded content from the server:
      scope.content.data = element.html()
      console.log 'include markup get preloaded:'
      console.log scope.content.data
      element.append($compile(template)(scope));
      return
  ])

