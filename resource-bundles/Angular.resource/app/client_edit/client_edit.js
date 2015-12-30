'use strict';

/* Controllers for client edit page */

angular.module('clientEditController', [
    'ngRoute',
    'mgcrea.ngStrap',
    'angularjs-dropdown-multiselect'
  ]);

angular.module('clientEditController')
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

    $scope.updateTags = function() {
      $scope.data.household.tags = _.intersection(
        $scope.tagDropdown.allTags, _.pluck($scope.tagDropdown.selected, 'id') );
      $scope.clientForm.$setDirty();
    };

    $scope.tagDropdown = {
      allTags: _.union(foundSettings.tags, foundHousehold.tags),
      options: _.map(_.union(foundSettings.tags, foundHousehold.tags), 
                        function(v) { return {id: v, label: v}; }),
      selected: _.map(foundHousehold.tags, function(v) { return {id: v, label: v}; }),
      events: {
        onItemSelect: $scope.updateTags,
        onItemDeselect: $scope.updateTags
      },
      settings: {
        showCheckAll: false,
        showUncheckAll: false
      }
    };

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
