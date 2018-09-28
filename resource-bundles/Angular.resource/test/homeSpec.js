'use strict';

/* jasmine specs for controllers go here */
/* global describe, beforeEach, it, inject, expect, module, jasmine, Visualforce */

describe('home', function() {

  var $rootScope, mockData;

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_) {
    $rootScope = _$rootScope_;

    mockData = function(method, index) {
      return Visualforce.remoting.mockData['FoodBankService.' + method][index].result;
    };
  }));

  describe('homeController', function(){
    var ctrl, scope, settings;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      settings = mockData('getAppSettings', 0);
      ctrl = $controller('homeController', {$scope: scope, foundSettings: settings});
    }));

    it('should have settings', function() {
      expect(scope.settings.general.Track_Checkout_Weight__c).toBe(true);
      expect(scope.settings.general.Track_Points__c).toBe(true);
    });
  });

  describe('homeController - not tracking points', function(){
    var ctrl, scope, settings;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      settings = mockData('getAppSettings', 0);
      settings.general.Track_Points__c = false;
      settings.general.Track_Checkout_Weight__c = false;
      ctrl = $controller('homeController', {$scope: scope, foundSettings: settings});
    }));

    it('should have settings', function() {
      expect(scope.settings.general.Track_Points__c).toBe(false);
      expect(scope.settings.general.Track_Checkout_Weight__c).toBe(false);
    });
  });

  
  describe('statsController', function(){
    var ctrl, scope, mockStatsFunction, $q;
  
    beforeEach(inject(function($controller, _$q_) {
      scope = $rootScope.$new();
      $q = _$q_;
      mockStatsFunction = { 
        get: function(tf){ 
          var deferred = $q.defer();
          deferred.resolve( mockData('getStats', 1) );
          return deferred.promise;
        }
      };      
      ctrl = $controller('statsController', {
        $scope: scope, 
        fbStats: mockStatsFunction
      });
      $rootScope.$apply();
    }));

    it('should have stats', function() {
      expect(scope.statsDropdown.length).toBe(11);
      expect(scope.timeframe).toBe('Today');
      expect(scope.stats.pointsUsed).toBe(8);
      scope.get('Last Week');
      expect(scope.timeframe).toBe('Last Week');
    });
  });
  
  // needs to be a child of home controller so $parent will work
  // needs to figure out how to mock the window alert
  
  // describe('checkInController', function(){
  //   var scope, ctrl, canceled, $window, rootScope, parent, settings;
  // 
  //   beforeEach(inject(function($controller, _$window_) {
  //     //$window = _$window_;
  //     settings = mockData('getAppSettings', 0);
  //     rootScope = $rootScope.$new();
  //     parent = $controller('homeController', {$scope: rootScope, foundSettings: settings});
  //     scope = $rootScope.$new();
  //     
  //     ctrl = $controller('checkInController', {
  //       $scope: scope,
  //       $window: _$window_,
  //       fbCancelCheckIn: function(clientId) {
  //         canceled = clientId;
  //       }
  //     });
  //   }));
  // 
  //   it('should have settings', function() {
  //     scope.client = { clientId: 'my-id' };
  //     scope.cancelCheckIn();
  //     expect(canceled).toBe('my-id');
  //   });
  // });

});