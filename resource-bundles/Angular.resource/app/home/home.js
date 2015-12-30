'use strict';

/* Controllers for main page */

angular.module('homeController', [
    'ngRoute',
    'mgcrea.ngStrap'
  ]);

angular.module('homeController')
  .controller('homeController', ['$scope', '$location', '$timeout', '$interval', 'fbCheckInList', 'fbHouseholdSearch', 'foundSettings', '$alert',
  function($scope, $location, $timeout, $interval, fbCheckInList, fbHouseholdSearch, foundSettings, $alert) {

    $scope.settings = foundSettings;

    $scope.searchClients = function(query) {
      //var soslRegex = /['!\(\)~\*-]/g;
      //var cleanedQuery = query.replace(soslRegex, '');
      //if (cleanedQuery && cleanedQuery.length >= 2)
      return fbHouseholdSearch.get(query, false);
    };

    $scope.checkIn = function(cid) {
      if (cid) {
        $location.url('/client/' + cid);
      }
    };

    $scope.refresh = function() {
      $scope.callingOut = true;

      fbCheckInList.get().then(
        function(result){
          $scope.checkedInClients = result;
          $timeout(function(){ $scope.callingOut = false; }, 750);
        },
        function(reason){
          $scope.callingOut = false;
          $alert({
            title: 'Failed.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.$on('$destroy', function() {
      $interval.cancel(repeater);
    });

    var repeater;
    $scope.refresh();
    repeater = $interval(function() { $scope.refresh(); }, 60000);
  }]);

angular.module('homeController')
  .controller('statsController', ['$scope', '$routeParams', '$cookies', 'fbStats', '$alert',
  function($scope, $routeParams, $cookies, fbStats, $alert) {

    $scope.statsDropdown = [
      { "text": "Today", "click": "get('Today')" },
      { "text": "Yesterday", "click": "get('Yesterday')" },
      { "divider": true },
      { "text": "This Week", "click": "get('This Week')" },
      { "text": "Last Week", "click": "get('Last Week')" },
      { "divider": true },
      { "text": "This Month", "click": "get('This Month')" },
      { "text": "Last Month", "click": "get('Last Month')" },
      { "divider": true },
      { "text": "This Year", "click": "get('This Year')" },
      { "text": "Last Year", "click": "get('Last Year')" }
    ];

    // calculate stats for the given timeframe, such as 'Last Week'
    $scope.get = function(tf) {
      $scope.calculating = true;
      $scope.timeframe = tf;
      $scope.timeframeCode = $scope.timeframe.replace(' ', '_').toUpperCase();
      fbStats.get( $scope.timeframeCode ).then(
        function(result){
          $scope.stats = result;
          $scope.calculating = false;
          $cookies.timeframe = $scope.timeframe;
        },
        function(reason){
          $scope.calculating = false;
          $alert({
            title: 'Failed to calculate statistics.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    // get the last timeframe from a cookie
    $scope.timeframe = $cookies.timeframe;
    if (!$scope.timeframe) {
      $scope.timeframe = 'Today';
    }
    
    $scope.get($scope.timeframe);
  }]);

angular.module('homeController')
  .controller('checkInController', ['$scope', '$window', 'fbCancelCheckIn',
    function($scope, $window, fbCancelCheckIn) {

    $scope.cancelCheckIn = function() {
      if ($window.confirm('Cancel visit for ' + $scope.client.clientName + '?')) {
        fbCancelCheckIn($scope.client.clientId);
        $scope.$parent.refresh();
      }
    };

  }]);
