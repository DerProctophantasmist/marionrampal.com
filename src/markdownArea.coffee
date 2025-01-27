module.exports = 'markdownArea'
EasyMDE = require('easymde')


markdownAreaCtrl =  ($scope, $element) ->
  this.editMode = false;
  this.editor = null;

  this.$postLink = ()=>
    console.log $element
    return
  
  this.handleModeChange = ()=>
    if (this.editMode) #save
      this.fieldValue = this.editor.value()
      this.editor.toTextArea()
      this.onUpdate({value: this.fieldValue})
      console.log this.fieldValue
    else      #edit
      console.log $element[0]
      this.editor = new EasyMDE (
        element: $element[0].getElementsByClassName('markdownArea')[0]
        autoDownloadFontAwesome: false
      ) 
      this.editor.value(this.fieldValue)
      
    this.editMode = !this.editMode
    
    return


  this.reset = ()=>
    this.editor.value(this.fieldValue)
    return

  
  return






require('angular').module('markdownArea', []).component('markdownArea', {
  template: '''
<textarea class="markdownArea" rows="10" cols="50" ng-show="$ctrl.editMode"  ng-model="$ctrl.fieldValue"></textarea>
<div ng-show="!$ctrl.editMode" marked="$ctrl.fieldValue"></div>
<button ng-click="$ctrl.handleModeChange()">{{$ctrl.editMode ? 'Save' : 'Edit'}}</button>
<button ng-show="$ctrl.editMode" ng-click="$ctrl.reset()">Reset</button>
  '''
  controller: markdownAreaCtrl
  bindings: {
    fieldValue: '<'
    onUpdate: '&'
  }
});