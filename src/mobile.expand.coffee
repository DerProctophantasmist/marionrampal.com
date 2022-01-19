module.exports = 'mobile.expand'

require('angular').module('mobile.expand', [
  require('angular-aside')
  require('./states')
  require('angular-marked')
  require('./markdownEditor')
]).
  factory('MobileExpand', ['$uibModal', 'State', 'marked', '$compile', ($uibModal, State, marked, $compile) ->
    window = null
    mobileExpand =  {
      refresh: ()->{}
      open: (content,popupLinks,classes) ->
        if window != null
          console.log "trying to open mobile expand window while it already is"
          return window
        window = $uibModal.open({
          windowTemplateUrl: 'templates/modalExpand.html',
          templateUrl: 'templates/mobileExpand.html',
          backdrop: true,
          # size: 'fs',
          controller: ['$scope', '$uibModalInstance', 'Sections',  'MarkdownEditor', ($scope, $uibModalInstance,Sections, MarkdownEditor) ->
            mobileExpand.refresh = () -> 
              $scope.$apply()
            # onCloseEditor = () =>
            #   content.editor.off('fileChange',onEdit)
            #   content.editor.off('onClose', onClose)
              
            this.title = 'Mobile Content'
            State.hideMainContent(true) 
            this.ok = (e) ->
              $uibModalInstance.close();
              # console.log "markdown: " + $scope.content.data
              e.stopPropagation() if e
            this.cancel = (e) ->
              $uibModalInstance.dismiss();
              # console.log "markdown: " + $scope.content.data
              e.stopPropagation() if e
            this.edit = (content) ->
              # DataFile.read(filename, fileCallbacks, $scope)  if !content.data
               # we are not actually using the editor reference, otherwise set
               # content.editor = 
              MarkdownEditor.open(content.localizedFilename, content.data) 
              # content.editor.on('fileChange', onEdit)
              # content.editor.on('close', onCloseEditor)
            # make some stuff accessible to the template, via the scope:
            $scope.content = content
            #this is for the editor: should we show it?
            $scope.globalState = State
            $scope.popupLinks = popupLinks
            

            return this
          ],
          controllerAs:'MobileContentCtrl',
          windowTopClass:'style2 white', 
          windowClass:'expanded-content'
        });
        window.result.then(( ->
            console.log('Closed window')
            State.hideMainContent(false)
            window = null
          ),( ->             
            console.log('Dismissed window')
            State.hideMainContent(false)
            window = null
        ))           
        return window.result;
      isOpen: ->
        return window != null
      close: ->
        if window == null 
          console.log("trying to close main window while not open")
          return
        window.close()
      dismiss: ->
        if window == null 
          console.log("trying to dismiss main window while not open")
          return
        window.dismiss()        
    }
    return mobileExpand
  ])
  
