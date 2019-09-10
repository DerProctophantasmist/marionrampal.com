module.exports = 'mobile.expand'

require('angular').module('mobile.expand', [require('angular-aside')]).
  factory('MobileExpand', ['$uibModal', ($uibModal) ->
    window = null
    return {
      open: (content,popupLinks) ->
        if window != null
          console.log "trying to open mobile expand window while it already is"
          return window
        window = $uibModal.open({
          templateUrl: 'templates/mobileExpand.html',
          backdrop: true,
          size: 'fs',
          controller: ['$scope', '$uibModalInstance', 'Sections', ($scope, $uibModalInstance,Sections) ->
            this.title = 'Mobile Content'
            this.ok = (e) ->
              $uibModalInstance.close();
              e.stopPropagation() if e
            this.cancel = (e) ->
              $uibModalInstance.dismiss();
              e.stopPropagation() if e
            $scope.content = content
            $scope.popupLinks = popupLinks
            return this
          ],
          controllerAs:'MobileContentCtrl',
          windowTopClass:'windowTopClass',
          windowClass:'windowClass'
        });
        window.result.then(( ->
            console.log('Closed window')
            window = null
          ),( ->             
            console.log('Dismissed window')
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
  ])
  
