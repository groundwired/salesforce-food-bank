'use strict';

/* Controllers */

angular.module('appControllers', []);

angular.module('appControllers')
  .controller('mainController', ['$scope', '$rootScope', 'basePath', '$alert', '$timeout', '$window',
  function($scope, $rootScope, basePath, $alert, $timeout, $window) {

    $scope.basePath = basePath;
    $scope.pathTo = function(fileName) { return basePath + '/' + fileName; };

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

angular.module('appControllers')
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

angular.module('appControllers')
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

angular.module('appControllers')
  .controller('checkInController', ['$scope', '$window', 'fbCancelCheckIn',
    function($scope, $window, fbCancelCheckIn) {

    $scope.cancelCheckIn = function() {
      if ($window.confirm('Cancel visit for ' + $scope.client.clientName + '?')) {
        fbCancelCheckIn($scope.client.clientId);
        $scope.$parent.refresh();
      }
    };

  }]);

angular.module('appControllers')
  .controller('clientController', ['$scope', '$location', '$timeout', '$window', '$routeParams', '$alert', 'foundSettings', 'foundHousehold', 'fbHouseholdDetail', 'fbSaveHousehold', 'fbCheckIn', 'fbVisitHistory',
  function($scope, $location, $timeout, $window, $routeParams, $alert, foundSettings, foundHousehold, fbHouseholdDetail, fbSaveHousehold, fbCheckIn, fbVisitHistory) {

    $scope.settings = foundSettings;

    $scope.data = {};
    $scope.data.household = foundHousehold;

    $scope.status = {};
    $scope.commodities = [];

    $scope.data.ptsRemaining = foundHousehold.currentPointsRemaining;
    $scope.data.ptsMonthly = foundHousehold.monthlyPointsAvailable;
    $scope.data.ratio =  Math.floor(foundHousehold.currentPointsRemaining * 100 / foundHousehold.monthlyPointsAvailable);
    $scope.data.boxType = foundHousehold.defaultBox;
    $scope.data.commodities = foundHousehold.commodityAvailability;
    $scope.data.visits = [];
    $scope.status.queriedVisits = false;

    $scope.data.memberList = [];
    _.forEach(foundHousehold.members, function(v) {
      $scope.data.memberList.push({
        memberData: _.clone(v)
      });
    });

    $scope.checkIn = function() {
      fbCheckIn($scope.data.household.id);
      $window.scrollTo(0,0);
      $alert({
        title: 'Checked in!',
        type: 'success',
        duration: 2
      });
      $timeout(function(){
        $location.url('/');
      }, 2000);
    };

    $scope.addMember = function() {
      $scope.data.memberList.push({
        memberData: {},
        memberDataEditable: {},
      });
    };

    $scope.cancelEdit = function() {
      $location.url('/');  // might want to go somewhere based on routing param
    };

    $scope.queryVisits = function() {
      if (!$scope.status.queriedVisits) {
        fbVisitHistory($scope.data.household.id).then(
          function(result) {
            $scope.data.visits = result;
            $scope.status.queriedVisits = true;
          },
          function(reason) {
            $alert({
              title: 'Failed to retrieve visit history.',
              content: reason.message,
              type: 'danger'
            });
            $scope.status.queriedVisits = true;
          }
        );
      }
    };

  }]);

angular.module('appControllers')
  .controller('clientEditController', ['$scope', '$location', '$timeout', '$window', '$routeParams', '$alert', 'foundSettings', 'foundHousehold', 'fbSaveHouseholdAndMembers',
  function($scope, $location, $timeout, $window, $routeParams, $alert, foundSettings, foundHousehold, fbSaveHouseholdAndMembers) {

    $scope.settings = foundSettings;

    $scope.data = {};
    $scope.data.household = foundHousehold;

    $scope.status = {};
    $scope.commodities = [];

    $scope.data.ptsRemaining = foundHousehold.currentPointsRemaining;
    $scope.data.ptsMonthly = foundHousehold.monthlyPointsAvailable;
    $scope.data.ratio =  Math.floor(foundHousehold.currentPointsRemaining * 100 / foundHousehold.monthlyPointsAvailable);
    $scope.data.boxType = foundHousehold.defaultBox;
    $scope.data.commodities = foundHousehold.commodityAvailability;

    $scope.data.memberList = [];
    _.forEach(foundHousehold.members, function(v) {
      $scope.data.memberList.push({
        memberData: _.clone(v)
      });
    });

    $scope.addMember = function() {
      $scope.status.editingMembers = true;
      $scope.data.memberList.push({
        memberData: {},
        memberDataEditable: {},
      });
    };

    $scope.saveClient = function() {
      $scope.status.savingClient = true;
      fbSaveHouseholdAndMembers($scope.data.household, $scope.data.memberList).then(
        function(result){
          $scope.data.household = result;
          $scope.data.memberList = [];
          _.forEach(foundHousehold.members, function(v) {
            $scope.data.memberList.push({
              memberData: _.clone(v)
            });
          });
          $alert({
            title: 'Saved.',
            type: 'success',
            duration: 1.5
          });
          $timeout(function(){
            if ($routeParams.action) {
              $location.url('/' + $routeParams.action + '/' + result.id);
            } else {
              $location.url('/client/' + result.id);
            }
          }, 1500);
        },
        function(reason){
          $scope.status.savingClient = false;
          $alert({
            title: 'Failed to save changes.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.cancelEdit = function() {
      $location.url('/');  // might want to go somewhere based on routing param
    };

  }]);

angular.module('appControllers')
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

angular.module('appControllers')
  .controller('addressController', ['$scope', '$alert', 'fbSaveHousehold',
    function($scope, $alert, fbSaveHousehold) {

    $scope.status.editingAddress = false;
    $scope.status.savingAddress = false;

    $scope.editAddress = function() {
      $scope.data.addressData = {
        id: $scope.data.household.id,
        address: $scope.data.household.address,
        city: $scope.data.household.city,
        state: $scope.data.household.state,
        postalCode: $scope.data.household.postalCode,
        phone: $scope.data.household.phone,
        homeless: $scope.data.household.homeless,
        proofOfAddress: $scope.data.household.proofOfAddress
      };
      $scope.status.editingAddress = true;
    };

    $scope.saveAddress = function() {
      $scope.status.savingAddress = true;
      fbSaveHousehold($scope.data.addressData, $scope.settings).then(
        function(result) {
          $scope.data.household = result;
          $scope.status.savingAddress = false;
          $scope.status.editingAddress = false;
        },
        function(reason) {
          $scope.status.savingAddress = false;
          $alert({
            title: 'Failed to save changes.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.cancelAddress = function() {
      $scope.status.editingAddress = false;
    };

  }]);

angular.module('appControllers')
  .controller('notesController', ['$scope', 'fbSaveHousehold', '$alert',
    function($scope, fbSaveHousehold, $alert) {

    $scope.status.editingNotes = false;
    $scope.status.savingNotes = false;

    $scope.editNotes = function() {
      $scope.data.notesData = {
        id: $scope.data.household.id,
        notes: $scope.data.household.notes,
      };
      $scope.status.editingNotes = true;
    };

    $scope.saveNotes = function() {
      $scope.status.savingNotes = true;
      fbSaveHousehold($scope.data.notesData).then(
        function(result){
          $scope.data.household = result;
          $scope.status.savingNotes = false;
          $scope.status.editingNotes = false;
        },
        function(reason){
          $scope.status.savingNotes = false;
          $alert({
            title: 'Failed to save changes.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.cancelNotes = function() {
      $scope.status.editingNotes = false;
    };
  }]);

angular.module('appControllers')
  .controller('memberListController', ['$scope', '$alert', 'fbSaveHouseholdMembers',
    function($scope, $alert, fbSaveHouseholdMembers) {

    $scope.status.editingMembers = false;
    $scope.status.savingMembers = false;

    $scope.editMembers = function() {
      _.forEach($scope.data.memberList, function(v) {
        v.memberDataEditable = v.memberData;
      });
      $scope.status.editingMembers = true;
    };

    $scope.deleteMember = function(i) {
      $scope.data.memberList.splice(i, 1);
    };

    $scope.saveMembers = function() {
      $scope.status.savingMembers = true;
      fbSaveHouseholdMembers($scope.data.household.id, _.map($scope.data.memberList, 'memberDataEditable')).then(
        function(result){
          $scope.data.household = result;
          $scope.data.memberList = [];
          _.forEach(result.members, function(v) {
            $scope.data.memberList.push({
              memberData: _.clone(v)
            });
          });
          $scope.status.savingMembers = false;
          $scope.status.editingMembers = false;
          $scope.$parent.$digest();
        },
        function(reason){
          $scope.status.savingMembers = false;
          $alert({
            title: 'Failed to save changes.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.cancelMembers = function() {
      $scope.status.editingMembers = false;
    };
  }]);

angular.module('appControllers')
  .controller('datepickerCtrl', ['$scope',
    function($scope) {

    $scope.openCal = function($event) {
      $scope.status.calOpen = !$scope.status.calOpen;
      $event.preventDefault();
      $event.stopPropagation();
    };

  }]);
