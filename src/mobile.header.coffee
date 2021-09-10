module.exports = 'mobileHeader'

require('angular').module('mobileHeader',[require("./section"), require('./quirks')])
.component('mobileHeader', {
  template: """
<h2 class="special-font text-center">
  <i18n ng-repeat="(lang,name) in $mobileHeader.secCtrl.section.name" lang="{{lang}}">
    {{name}}
  <i18n>
</h2>
  """,
  transclude: true,
  bindings: {},
  require: 
    secCtrl: '^?section'
  controller: ['Quirks', (Quirks) ->  
      this.shown = ()-> 
        Quirks.isMobileLayout()
              
      return
    ],
  controllerAs: '$mobileHeader'
})
