'use strict';
/* global _ */

/* Controllers for client edit page */
angular.module('clientEditController', [
    'ngRoute',
    'angularjs-dropdown-multiselect'
  ]);

angular.module('clientEditController')
  .controller('clientEditController', ['$scope', '$location', '$timeout', '$window', '$routeParams', '$alert', '$modal', 'foundSettings', 'foundHousehold', 'basePath', 'fbSaveHouseholdAndMembers',
  function($scope, $location, $timeout, $window, $routeParams, $alert, $modal, foundSettings, foundHousehold, basePath, fbSaveHouseholdAndMembers) {

    $scope.settings = foundSettings;

    $scope.data = {};
    $scope.data.household = foundHousehold;

    $scope.status = {};
    $scope.commodities = [];

    $scope.data.ptsRemaining = foundHousehold.currentPointsRemaining;
    $scope.data.ptsMonthly = foundHousehold.monthlyPointsAvailable;
    $scope.data.ratio =  Math.floor(foundHousehold.currentPointsRemaining * 100 / foundHousehold.monthlyPointsAvailable);
    $scope.data.boxType = foundHousehold.defaultBox;
    $scope.data.checkoutWeight = 0.0;
    $scope.data.commodities = foundHousehold.commodityAvailability;

    $scope.data.tagsData = {
      id: $scope.data.household.id,
      tags: $scope.data.household.tags
    };

    $scope.updateTags = function() {
      $scope.data.tagsData.tags = _.intersection(
        $scope.tagDropdown.allTags, _.pluck($scope.tagDropdown.selected, 'id') );
      $scope.clientForm.$setDirty();
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

    $scope.data.memberList = [];
    _.forEach(foundHousehold.members, function(v) {
      $scope.data.memberList.push({
        memberData: _.clone(v)
      });
    });

    $scope.addMember = function() {
      $scope.status.editingMembers = true;
      $scope.data.memberList.push({
        memberData: {}
      });
    };

    $scope.saveClient = function() {
      $scope.status.savingClient = true;
      _.assign($scope.data.household, $scope.data.tagsData);
      fbSaveHouseholdAndMembers($scope.data.household, _.map($scope.data.memberList, 'memberData')).then(
        function(result){
          $scope.data.household = result;
          $scope.data.memberList = [];
          _.forEach(result.members, function(v) {
            $scope.data.memberList.push({
              memberData: _.clone(v)
            });
          });
          $scope.data.tagsData = {
            id: $scope.data.household.id,
            tags: $scope.data.household.tags
          };
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

    var deleteModal;
    $scope.deleteMember = function(i) {
      if (!!$scope.data.memberList[i].memberData.id) {
        deleteModal = $modal({title: 'Delete Household Member', contentTemplate: basePath + '/app/client/delete_modal.html', show: false, scope: $scope});
        deleteModal.memberIndex = i;
        deleteModal.show();
      } else {
        $scope.data.memberList.splice(i, 1);
      }
    };

    $scope.cancelEdit = function() {
      $location.url('/');  // might want to go somewhere based on routing param
    };

  }]);
