'use strict';

/* Controllers for client view page */

angular.module('clientController', [
    'ngRoute',
    'mgcrea.ngStrap',
    'angularjs-dropdown-multiselect'
  ]);

angular.module('clientController')
  .controller('clientController', ['$scope', '$location', '$timeout', '$window', '$routeParams', '$alert', '$q', 'foundSettings', 'foundHousehold', 'fbHouseholdDetail', 'fbSaveHousehold', 'fbSaveHouseholdMembers', 'fbSaveHouseholdAndMembers', 'fbCheckIn', 'fbVisitHistory',
  function($scope, $location, $timeout, $window, $routeParams, $alert, $q, foundSettings, foundHousehold, fbHouseholdDetail, fbSaveHousehold, fbSaveHouseholdMembers, fbSaveHouseholdAndMembers, fbCheckIn, fbVisitHistory) {

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

    //determine if this client has exceeded the food bank visit frequency limit and set warning message appropriately
    $scope.visitorWarningMsg = function() {
      if (foundSettings.general.visitFrequencyLimit.toUpperCase() === "WEEKLY") {
        //we assume weekly means a visit once per calendar week, with the week starting on Sunday
        //first determine the day of th week of today
        if (moment().week() === moment($scope.data.household.mostRecentVisitDate).week() && (moment().diff($scope.data.household.mostRecentVisitDate,'days') <= 7)) {
          return "Heads up! This client has already visited in the past calendar week.";
        } else {
          return;
        }
      } else if (foundSettings.general.visitFrequencyLimit.toUpperCase() === "BIWEEKLY") {
        if ( ((moment().week() === moment($scope.data.household.mostRecentVisitDate).week()) || (moment().subtract(1,'weeks').week() === moment($scope.data.household.mostRecentVisitDate).week())) && (moment().diff($scope.data.household.mostRecentVisitDate,'days') <= 14)) {
          return "Heads up! This client has already visited in the past two calendar weeks.";
        } else {
          return;
        }
      } else if (foundSettings.general.visitFrequencyLimit.toUpperCase() === "MONTHLY") {
        if (moment().month() === moment($scope.data.household.mostRecentVisitDate).month() && (moment().diff($scope.data.household.mostRecentVisitDate,'days') <= 31)) {
          return "Heads up! This client has already visited in the past calendar month.";
        } else {
          return;
        }
      } else if (foundSettings.general.visitFrequencyLimit && foundSettings.general.visitFrequencyLimit.toUpperCase().match(/^EVERY\s+.*$/)) {
        var noOfDays = parseInt(/\d+/.exec(foundSettings.general.visitFrequencyLimit));
        if (moment().diff($scope.data.household.mostRecentVisitDate,'days') < noOfDays) {
          return "Heads up! This client has already visited in the past " + noOfDays + " days.";
        } else {
          return;
        }
      } else {
        return;
      }
    };

    $scope.somethingIsBeingEdited = function() {
      return ($scope.status.editingAddress && $scope.status.editingNotes && $scope.status.editingTags && $scope.status.editingMembers);
    };

    $scope.saveAll = function() {
      var soon = $q.defer();
      $scope.data.allData = {};
      if ($scope.status.editingAddress) {
        _.assign($scope.data.allData, $scope.data.addressData);
        $scope.status.savingAddress = true;
      }
      if ($scope.status.editingTags) {
        _.assign($scope.data.allData, $scope.data.tagsData);
        $scope.status.savingTags = true;
      }
      if ($scope.status.editingNotes) {
        _.assign($scope.data.allData, $scope.data.notesData);
        $scope.status.savingNotes = true;
      }
      if ($scope.status.editingMembers) {
        $scope.status.savingMembers = true;

        if (_.isEqual($scope.data.allData, {})) {
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
              soon.resolve();
            },
            function(reason){
              $scope.status.savingClient = false;
              $alert({
                title: 'Failed to save changes.',
                content: reason.message,
                type: 'danger'
              });
              soon.reject();
            }
          );
        } else {
          fbSaveHouseholdAndMembers($scope.data.allData, _.map($scope.data.memberList, 'memberDataEditable')).then(
            function(result){
              $scope.data.household = result;
              $scope.data.memberList = [];
              _.forEach(foundHousehold.members, function(v) {
                $scope.data.memberList.push({
                  memberData: _.clone(v)
                });
              });
              $scope.status.savingMembers = false;
              $scope.status.editingMembers = false;
              soon.resolve();
            },
            function(reason){
              $scope.status.savingClient = false;
              $alert({
                title: 'Failed to save changes.',
                content: reason.message,
                type: 'danger'
              });
              soon.reject();
            }
          );
        }
      } else if (!_.isEqual($scope.data.allData, {})) {
        fbSaveHousehold($scope.data.allData, $scope.settings).then(
          function(result) {
            $scope.data.household = result;
            $scope.status.savingAddress = false;
            $scope.status.editingAddress = false;
            $scope.status.savingTags = false;
            $scope.status.editingTags = false;
            $scope.status.savingNotes = false;
            $scope.status.editingNotes = false;
            soon.resolve();
          },
          function(reason) {
            $scope.status.savingAddress = false;
            $scope.status.savingTags = false;
            $scope.status.savingNotes = false;
            $alert({
              title: 'Failed to save changes.',
              content: reason.message,
              type: 'danger'
            });
            soon.reject();
          }
        );
      } else {
        soon.resolve();
      }
      return soon.promise;
    };

    $scope.checkIn = function() {
      $scope.saveAll().then(function() {
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
      });
    };

    $scope.recordVisit = function() {
      $scope.saveAll().then(function() {
        $location.url('/log_visit/' + $scope.data.household.id);
      });
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

angular.module('clientController')
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

angular.module('clientController')
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

angular.module('clientController')
  .controller('tagsController', ['$scope', 'fbSaveHousehold', '$alert',
    function($scope, fbSaveHousehold, $alert) {

    $scope.status.editingTags = false;
    $scope.status.savingTags = false;

    $scope.data.tagsData = {
      id: $scope.data.household.id,
      tags: $scope.data.household.tags,
    };

    $scope.updateTags = function() {
      $scope.data.tagsData.tags = _.intersection(
        $scope.tagDropdown.allTags, _.pluck($scope.tagDropdown.selected, 'id') );
    };

    $scope.tagDropdown = {
      allTags: _.union($scope.settings.tags, $scope.data.household.tags),
      options: _.map(_.union($scope.settings.tags, $scope.data.household.tags), 
                        function(v) { return {id: v, label: v}; }),
      selected: _.map($scope.data.household.tags, function(v) { return {id: v, label: v}; }),
      events: {
        onItemSelect: $scope.updateTags,
        onItemDeselect: $scope.updateTags
      },
      settings: {
        showCheckAll: false,
        showUncheckAll: false,
        dynamicTitle: false
      }
    };

    $scope.editTags = function() {
      $scope.status.editingTags = true;
    };

    $scope.saveTags = function() {
      $scope.status.savingTags = true;
      fbSaveHousehold($scope.data.tagsData).then(
        function(result){
          $scope.data.household = result;
          $scope.status.savingTags = false;
          $scope.status.editingTags = false;
        },
        function(reason){
          $scope.status.savingTags = false;
          $alert({
            title: 'Failed to save changes.',
            content: reason.message,
            type: 'danger'
          });
        }
      );
    };

    $scope.cancelTags = function() {
      $scope.data.tagsData.tags = $scope.data.household.tags;
      $scope.tagDropdown.selected = _.map($scope.data.household.tags, function(v) { return {id: v, label: v}; });
      $scope.status.editingTags = false;
    };
  }]);

angular.module('clientController')
  .controller('memberListController', ['$scope', '$alert', '$modal', 'basePath', 'fbSaveHouseholdMembers',
    function($scope, $alert, $modal, basePath, fbSaveHouseholdMembers) {

    $scope.status.editingMembers = false;
    $scope.status.savingMembers = false;

    $scope.editMembers = function() {
      _.forEach($scope.data.memberList, function(v) {
        v.memberDataEditable = v.memberData;
      });
      $scope.status.editingMembers = true;
    };

    var deleteModal;
    $scope.deleteMember = function(i) {
      if (!!$scope.data.memberList[i].memberData.id) {
        deleteModal = $modal({title: 'Delete Household Member', contentTemplate: basePath + '/partials/delete_modal.html', show: false, scope: $scope});
        deleteModal.memberIndex = i;
        debugger;
        deleteModal.show();
      } else {
        $scope.data.memberList.splice(i, 1);
      }
    };

    $scope.deleteClient = function() {
      $scope.data.memberList.splice(deleteModal.memberIndex, 1);
    };

    $scope.moveClient = function() {
      $scope.data.memberList.splice(deleteModal.memberIndex, 1);
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

angular.module('clientController')
  .controller('datepickerCtrl', ['$scope',
    function($scope) {

    $scope.openCal = function($event) {
      $scope.status.calOpen = !$scope.status.calOpen;
      $event.preventDefault();
      $event.stopPropagation();
    };

  }]);
