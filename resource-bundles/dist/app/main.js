'use strict';

/* Controllers */

angular.module('mainController', [
    'ngRoute'
  ]);

angular.module('mainController')
  .controller('mainController', ['$scope', '$rootScope', 'basePath', '$alert', '$timeout', '$window',
  function($scope, $rootScope, basePath, $alert, $timeout, $window) {

    $rootScope.basePath = basePath;
    
    $rootScope.status = {};
    $rootScope.status.loading = false;

    $scope.$on("alert:nosession", function() {
      $alert({
        title: 'You do not appear to be logged in!',
        content: 'Reloading the page...',
        type: 'warning',
        duration: 1.9
      });
      $timeout(function(){
        $window.location.reload();
      }, 2000);
    });

    $scope.$on("alert:offline", function() {
      $alert({
        title: 'You do not appear to be connected to the internet.',
        content: 'Please check your connection and then refresh the page.',
        type: 'danger'
      });
    });

    $rootScope.$on("$routeChangeStart", function(event, next, current) {
      $rootScope.status.loading = true;
    });
    $rootScope.$on("$routeChangeSuccess", function(event, current, previous) {
      $rootScope.status.loading = false;
    });
    $rootScope.$on("$routeChangeError", function(event, current, previous, rejection) {
      $rootScope.status.loading = false;
      $alert({
        title: 'Failed.',
        content: rejection.message,
        type: 'danger'
      });
    });
  }]);
