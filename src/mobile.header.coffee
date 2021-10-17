module.exports = 'mobileHeader'

require('angular').module('mobileHeader',[require("./section"), require('./quirks')])
.component('mobileHeader', {
  template: """
<h2 class="special-font text-center" ng-show="$mHC.shown()">
  <span ng-if="!$mHC.NameIsLocalised()">{{$mHC.secCtrl.section.name}}</span>
  <ng-if  ng-if="$mHC.NameIsLocalised()">
    <span ng-repeat="(lang,name) in $mHC.secCtrl.section.name" i18n="{{lang}}">
      {{name}}
    <span>
  </ng-if>
</h2>
  """,
  transclude: true,
  bindings: {},
  require: 
    secCtrl: '^?section'
  controller: ['Quirks', (Quirks) ->  
      this.shown = ()-> 
        return true
        Quirks.isMobileLayout()
      this.NameIsLocalised = ()->
        if typeof this.secCtrl.section.name == 'string'
         return false
        return true              
      return
    ],
  controllerAs: '$mHC'
})
