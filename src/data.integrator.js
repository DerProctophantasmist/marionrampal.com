(function () {

    module.exports = 'data.integrator';

    var angular = require('angular');
    require('angular-lazy-image');
    require('angular-ui-bootstrap');
    require('angular-bootstrap-lightbox');
    require('angular-touch');
    require('angular-loading-bar');
    require('ng-videosharing-embed');
    require('angular-animate');
    require('angular-marked');


    
    var modData = angular.module('data.integrator', [
        'afkl.lazyImage', 'hc.marked',
        'bootstrapLightbox', 'ngTouch', 'angular-loading-bar',
        'ngAnimate', 'ui.bootstrap', 'videosharing-embed',
        require('angular-marked'), require('./oEmbed'), require('./contact.form'), require('./section'),
        require('./calendar'), require('./include.markup'), require('./config'), require('./quirks'),
        require('./language.picker'), require('./render.json')
    ]).config(['markedProvider', function (markedProvider) {
        markedProvider.setOptions({gfm: true, breaks:true});
    }]);;
    
    
//    var sectionCtrl = ['$scope', function($scope){            
//            $scope.activated = false;
//            this.activate = function(status){
//                $scope.activated = status;
//            };
//    }];

    function getPageTemplateUrl(type) {
        switch (type) {
            case 'intro':
                return '/page_intro.html';
            case 'main':
                return '/page_standard.html';
            case 'collection':
                return '/page_collection.html';

        }
    }


//    modData.directive("page", function () {
//        return {
//            restrict: 'E',
//            scope: false,
//            replace: true,
//            link: function (scope, elt, attrs) {
//            }
//        };
//    });


    var boxCtrl = ['$scope', 'Quirks', function ($scope, Quirks) {
            if (Quirks.isMobileLayout()) $scope.header = $scope.box["mobile-header"];
            $scope.content = $scope.box.content;
            $scope.popupLinks = [];
            $scope.getPopupLinks = function () {
                return $scope.popupLinks;
            };
        }];


    modData.directive("renderJson", ['$compile', '$interpolate', 'Config', 'JsonRenderer',  function ($compile, $interpolate,  Config, JsonRenderer) {
        
            
            return {
                restrict: 'A',
                scope: false,
                replace: false,
                link: function (scope, elt, attrs) {
                    var json = scope[attrs.renderJson];
                    var newScope = scope.$new(false);
                    var html = JsonRenderer(json);
                    elt.append($compile(html)(newScope));
                                            }
            };
        }]);

    modData.directive("popupLink", ['Lightbox', function (Lightbox) {
            return{
                restrict: 'A',
                scope: false,
                replace: false,
                link: function (scope, elt, attrs) {
                    scope.popupLinks.push({type: attrs.popupLink, url: attrs.url, contentSettings: attrs.contentSettings});
                    var index = scope.popupLinks.length - 1;
                    var wClass = {video: 'video-container'}[attrs.popupLink];
                    elt.bind('click', function () {
                        Lightbox.openModal(scope.popupLinks, index, {'templateUrl': "lightbox.html", 'windowTopClass': wClass});
                    });

                }
            };

        }]);
    modData.directive("i18n", ['Locale', function(Locale){
            return {
                restrict: 'EA',
                scope: {i18n:'@', lang:'@'},
                replace: false,
                transclude: true,
                link: function(scope){
                    scope.getlocale = function () {
                        return Locale.get().language;
                    }
                },
                template: '<ng-if ng-if="getlocale()==(i18n?i18n:lang)"><ng-transclude></ng-transclude></ng-if>'
            };
            
    }]);


    modData.controller('BoxCtrl', boxCtrl);//.controller('SectionCtrl', sectionCtrl);
  

}());
 