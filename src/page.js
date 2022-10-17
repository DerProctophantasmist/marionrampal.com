// Generated by CoffeeScript 2.6.1
(function() {
  module.exports = 'page';

  require('angular').module('page', [require("./sections.ng"), require("./section")]).component('page', {
    // <article id="{{page.id}}" 
    //     in-view='$pc.website.Activate.page($inview, page, $inviewInfo)' in-view-options="inViewOptions"  
    //     data-afkl-lazy-image="{{page.bkgImg}}" data-afkl-lazy-image-options='{"background": true,"nolazy":true}' 
    //     ng-class="[page.type + ' ' + page.theme + ' main lazy fullscreen full-gravity', {'inactive': !page.active}]"
    //     ng-style="{'background-position':page.bkgImgPos, 'min-height':$pc.website.androidHeightHack()}"  du-scrollspy >
    template: `<article id={{$pc.page.id}}
    in-view='$pc.website.Activate.page($inview, $pc.page, $inviewInfo)' in-view-options="{throttle:30,offset:[-40,0,-40,0]}"  
    data-afkl-lazy-image="{{$pc.page.bkgImg}}" data-afkl-lazy-image-options='{"background": true,"nolazy":true}' 
    ng-class="[$pc.page.type + ' ' + $pc.page.theme + ' main lazy fullscreen full-gravity', {'inactive': !$pc.page.active}]"
    ng-style="{'background-position':$pc.page.bkgImgPos, 'min-height':$pc.website.androidHeightHack()}"  du-scrollspy >
  <ng-transclude ng-if="!$pc.empty"></ng-transclude>

  <a ng-if="$pc.website.displayNextPage($pc.page)" href="\#{{$pc.page.next.id}}" du-smooth-scroll class="button down anchored">More</a>
</article>`,
    transclude: true,
    bindings: {
      pageData: '@'
    },
    controller: [
      '$scope',
      function($scope) {
        $scope.$pc = this;
        this.empty = false;
        this.$postLink = () => {
          var $cur,
      e;
          $cur = $scope;
          while (true) {
            $cur = $cur.$parent;
            if ($cur === null) {
              throw new ReferenceError(`page ${page.id} cannot find parent section`);
            }
            if (this.sectCtrl == null) {
              this.secCtrl = $cur.$sc;
            }
            if (this.website == null) {
              this.website = $cur.website;
            }
            if ((this.secCtrl != null) && (this.website != null)) {
              break;
            }
          }
          if (this.page == null) {
            try {
              this.page = JSON.parse(this.pageData);
            } catch (error) {
              e = error;
              console.log("data for the page is not well formed: " + e.toString());
              return;
            }
          }
          this.secCtrl.section.addPage(this.page);
        };
        this.$onDestroy = () => {
          return this.page.destroy();
        };
      }
    ],
    controllerAs: '$pc'
  });

}).call(this);

//# sourceMappingURL=page.js.map