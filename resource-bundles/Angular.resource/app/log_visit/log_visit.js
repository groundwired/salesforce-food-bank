'use strict';

/* Controllers for log visit page */

angular.module('logVisitController', [
    'ngRoute',
    'mgcrea.ngStrap'
  ]);

angular.module('logVisitController')
  .controller('logVisitController', ['$scope', '$routeParams', '$timeout', '$window', '$location', 'foundHousehold', 'foundSettings', 'fbLogVisit', '$alert',
    function($scope, $routeParams, $timeout, $window, $location, foundHousehold, foundSettings, fbLogVisit, $alert) {

    $scope.household = foundHousehold;
    $scope.settings = foundSettings;
    $scope.commodities = foundSettings.commodities;

    $scope.logging = false;
    $scope.addressEdit = false;

    $scope.ptsUsed = 0;
    $scope.ptsRemaining = foundHousehold.currentPointsRemaining;
    $scope.ptsMonthly = foundHousehold.monthlyPointsAvailable;
    $scope.ratio =  Math.floor($scope.ptsRemaining * 100 / $scope.ptsMonthly);
    $scope.boxType = foundHousehold.defaultBox;
    $scope.commodities = foundHousehold.commodityAvailability;

    $scope.visitNotes = '';
    
    $scope.recordVisit = function() {

      // gather the commodity usage for this visit        
      var comms = {};
      _.forEach( $scope.commodities, function(v) {
        if (v.ptsUsed > 0) {
          comms[v.name] = v.ptsUsed;
        }
      });

      $scope.logging = true;
      fbLogVisit( $scope.household.id, $scope.boxType, $scope.ptsUsed, comms, $scope.visitNotes ).then(
        function(result){
          $scope.logging = false;
          $window.scrollTo(0,0);
          $alert({
            title: 'Visit recorded.',
            type: 'success',
            duration: 2
          });
          $timeout(function(){
            $location.url('/');
          }, 2000);
        },
        function(reason){
          $scope.logging = false;
          $alert({
            title: 'Failed to record visit.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };
  }]);
