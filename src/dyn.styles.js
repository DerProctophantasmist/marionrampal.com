
var angular = require('angular');
var modStyles = angular.module('dyn.styles', [ require('./states')]);



//var modTools = angular.module('gen.tools',[]);

Array.prototype.mergeAsSet = function (a) {
    for (var i = 0; i < this.length; ++i) {
        for (var j = 0; j < a.length; ++j) {
            if (this[i] === a[j])
                a.splice(j--, 1);
        }
    }

    return this.concat(a);
};

function GoogleFonts() {
    var fontList = {};
    this.add = function (fontFamily, fontStyles) {
        var font = fontList[fontFamily];

        if (font !== undefined) {
            fontList[fontFamily] = font.mergeAsSet(fontStyles);
        } else
            fontList[fontFamily] = fontStyles;
    };
    this.addFonts = function (fonts)
    {
        for (var family in fonts) {
            this.add(family, fonts[family]);
        }
    };
    this.url = function () {
        var url = "https://fonts.googleapis.com/css?family=";
        var first = true;
        for (var family in fontList) {
            if (!first)
                url += '|';
            else
                first = false;
            url += encodeURIComponent(family).replace(/%20/g, "+");
            var f = true;
            fontList[family].forEach(function (style) {
                if (!f)
                    url += ',';
                else {
                    url += ':';
                    f = false;
                }
                url += style;
            });
        }
        if (first)
            return undefined;
        else
            return url + '&subset=latin-ext';
    };
}

modStyles.service('googleFonts', GoogleFonts);


//hrefGoogleFonts should be a JSON encoding of: {<
modStyles.directive("importGoogleFonts", ['googleFonts', function (googleFonts) {
        return {
            restrict: 'E',
            template: '<link ng-href="{{googleFontService.url()}}" rel="stylesheet" type="text/css" />',
            controller: ['$scope', function ($scope) {
                    $scope.googleFontService = googleFonts;
                }],
            scope: {},
            replace: true
        };

    }]);


modStyles.directive("fontStyle", ['googleFonts', function (googleFonts) {
        return {
            restrict: 'E',
            template: '<style >' +
                    '{{cssSelector}} {{cssFontClass}} {' +
                    'font-family: "{{font().family}}";' +
//                        'font-size-adjust:0.5;'+
                    '}' +
                    '</style>',
            scope: {font: '&', cssSelector: '@', cssFontClass: '@'},
            replace: true//, 
//            link: function (scope, elt, attrs) {
//                if (scope.googleFont !== undefined) googleFonts.add(scope.font().family, scope.font().styles);
//                attrs.href = googleFonts.url();
//            }
        };

    }]);


modStyles.value('dynSvg', {});

modStyles.directive("fullsiteonly",[function () {
    return {
        restrict: 'A',
        controller: ['State', function(State){ 
            this.shown = function(){
                return !State.singleSection();
            };
        }],
        scope:{},
        controllerAs: '$c',
        transclude: true,
        template: '<ng-transclude ng-show="$c.shown()" />'
    };

}]);

module.exports = 'dyn.styles';