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
        require('angular-marked'), require('./oEmbed'), require('./contact.form'),
        require('./calendar'), require('./include.markup'), require('./config'), require('./quirks'),
        require('./language.picker')
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


    modData.directive("renderJson", ['$compile', '$interpolate', 'Config',   function ($compile, $interpolate,  Config) {
        var escape = function(str){
            
            //nueuuasrege!
            switch(str){
                case "\n":
                    return "\\n";
                case "\"":
                    return "\\&quot;";               
            }
            return str;
        };
        var htmlXtension = {
            youtube: function (config) {
                config.playlist = config.playlist || Config.defaultYoutubePlaylist;
                return '<a popup-link="video" style="position:relative;" class="image half centered popup-link" data-url="https://www.youtube.com/watch?v=' + config.id + '" content-settings="{&quot;list&quot;:&quot;' + config.playlist +
                        '&quot;}"><img src="//img.youtube.com/vi/' + config.id + '/hqdefault.jpg" /><span class="play-button"></span></a>';
            },
            'google-calendar': function(config) {
                return '<google-calendar id="' + config.id + '"></google-calendar>';
            },
            'include-markup': function(config) {
                if (!config.filename){
                    console.log("include-markup should define the filename attribute");
                    return "";
                }
                config.caption = config.caption || "";
                config.chapeau = config.chapeau || "";
                config.inline = Boolean(config.inline) || false;
                config.main = Boolean(config.main) || false;
                
                if( typeof config.chapeau === "object"){ //i18n
                    chapeau = '{'
                    var i = 0;
                    for (var key in config.chapeau) {
                        chapeau += (i++? ',':'') + '&quot;'+ key + '&quot;:&quot;' + config.chapeau[key].replace(/[\n\\\"]/g,escape) + '&quot;';
                    } 
                    chapeau += '}';
                    config.chapeau = chapeau;
                    
                }
                else config.chapeau = '&quot;' + config.chapeau.replace(/[\n\\\"]/g,escape) + '&quot;';
                
                return '<include-markup content="{&quot;filename&quot;:&quot;' + config.filename +
                        '&quot;,&quot;caption&quot;:&quot;' + config.caption +
                        '&quot;,&quot;chapeau&quot;:' + config.chapeau + ',' +
                        '&quot;inline&quot;:' + config.inline +
                        ',&quot;main&quot;:' + config.main +
                        '}" popup-links="popupLinks"></include-markup>';
            }
        };
        
            return {
                restrict: 'A',
                scope: false,
                replace: false,
                link: function (scope, elt, attrs) {
                    var json = scope[attrs.renderJson];
                    if (angular.isArray(json) && json.length) {
                        json.forEach(function (node)
                        {
                            var newScope = scope.$new(false);
                            newScope.node = node;
                            var html;
                            var compile = $compile;
                            var hasChild = false;
                            switch (typeof node)
                            {
                                case "string":
                                    html = '<marked compile="true">'+node+'</marked>';
                                    break;
                                case "object":
                                {
                                    compile = $compile;
                                    if (node.xtended === undefined)
                                    {
 
                                        var attrs = "";
                                        for (var key in node) {
                                            if (key[0] === '@')
                                                attrs += ' ' + key.substring(1) + '="' + node[key] + '"';
                                            else {
                                                newScope.children = node[key];
                                                newScope.tag = key;
                                                if (node[key]) hasChild = true;
                                            }
                                        }
                                        html = "<" + newScope.tag + attrs + ((hasChild)? ' render-json="children"' : "") + " />";
                                    }
                                    else
                                        html = htmlXtension[node.xtended](node);
                                    break;

                                } 
                            }


                            elt.append(compile(html)(newScope));
                        });

                    } else if (typeof json === "string")
                    {
                        elt.append($interpolate(json)(scope));
                    }
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
                        Lightbox.openModal(scope.popupLinks, index, {'templateUrl': "/lightbox.html", 'windowTopClass': wClass});
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
                template: '<ng-show ng-show="getlocale()==(i18n?i18n:lang)"><ng-transclude></ng-transclude></ng-show>'
            };
            
    }]);


    modData.controller('BoxCtrl', boxCtrl);//.controller('SectionCtrl', sectionCtrl);
  

}());
 