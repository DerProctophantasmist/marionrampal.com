
module.exports = 'contactForm'


require('angular').module('contactForm', [require('./config')])
  .directive("contactForm", [()->
      restrict: 'AE',
      templateUrl:'templates/contact.html',
      scope:false
      replace: true,
      controller: ['$scope', '$http', "$location", "Config", ($scope,$http, $location, Config) ->
        $scope.msg = {};

        $scope.submit = () ->
          $scope.msg 
          $scope.msg.error = null
          $scope.msg.result = null
          $scope.submitting = true
          
          $http.post(Config.ajaxHost('contact'),$scope.msg).then( (res)->
              $scope.submitting = false
              $scope.msg = {}
              $scope.msg.error = false
              $scope.msg.result = res.data.txt     
              $scope.contactForm.$setPristine()
              $scope.contactForm.$setUntouched()
            ,
            (res) -> 
              # we reset to pristine  every time the user submit EVEN IF WE DON'T RESET THE CONTENT (in case of error)
              $scope.submitting = false
              $scope.contactForm.$setPristine()
              $scope.contactForm.$setUntouched()
              $scope.msg.error = true
              $scope.msg.result = "Le message n'a pas pu être envoyé: " + res.data.txt      
          )
      ]
  ])
  .controller("formCtrl", ['$scope',($scope)->
    $scope.focused = false
  ])
  