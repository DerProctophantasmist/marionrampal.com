(function () {   

    var angular = require('angular');   
     

    var app = angular.module('single.page.site', [
        require('./dyn.styles'), require('./data.integrator'),
        require('./config'), 
        require('./modal'),
        require('./scrolling'),
        require('./quirks'),
        require('./states'),
        require('./language.picker'),
        require('./preloaded'),
        require('angular-loading-bar'), require('angular-animate')
    ]); 
    //var modTools = angular.module('gen.tools',[]);

 
    app.filter('defaultsTo', function () {
        return function (input, defaultValue) {
            if (angular.isUndefined(input) || input === null || input === '') {
                return defaultValue;
            }

            return input;
        };
    }); 
    
    app.filter('decodeURIComponent', function(){
        return decodeURIComponent
    })

 
    var websiteCtrl = ['$scope', 'googleFonts', 'Activate', 'Sections', 'Quirks', 'State','Locale',
        function ($scope, googleFonts, Activate, Sections,  Quirks, State, Locale) {
            this.title = 'Marion Rampal';
            var website = this;
            
            website.sections = Sections; 
            website.isMobileLayout = Quirks.isMobileLayout;             
            website.androidHeightHack = Quirks.androidHeightHack;
            website.locale = Locale;
            website.state = State;

            website.getCarouselInterval = State.getCarouselInterval;

            website.init = function (prefLang,forceLang,allowEdit) {
                Locale.init(prefLang,forceLang);
                State.setAllowEdit(allowEdit);
            }
            
            website.headerImage = function () {
                return (!Quirks.isMobileLayout() && Sections.topPage) ?  Sections.topPage.bkgImg : "";
            };
            website.headerColor = function() {
                return (Sections.topPage)? (Sections.topPage.headerColor || "#FFF") :"#FFF";
            }
            website.menuBackground = function () {
                return (Sections.topPage) ? (Sections.topPage.menuBkg || "" ): "";
            };
            
            website.displaySection = State.isSectionToDisplay;
            
            website.displayNextPage = function(page) {
                return page.next != null && (page.next.section.id === page.section.id || State.isSectionToDisplay(page.next.section.id));
            };
                    
                        
            Sections.onLoad(function(section){                
                if (section.googleFont !== undefined && section.googleFont.family !== undefined)
                    googleFonts.add(section.googleFont.family, section.googleFont.styles);
                
            });
            website.Activate = Activate;

            website.isMainContentHidden = State.isMainContentHidden
            
            
            website.inViewOptions = {throttle:30,offset:[-40,0,-40,0]};
            
        }];
    
  app.controller('WebsiteCtrl', websiteCtrl);

}());
   