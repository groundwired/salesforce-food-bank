'use strict';

/* jasmine specs for controllers go here */
/* global describe, beforeEach, it, inject, expect, module, jasmine */

describe('log_visit', function() {

  var $rootScope, mockData;

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_) {
    $rootScope = _$rootScope_;

    mockData = function(method, index) {
      return Visualforce.remoting.mockData['FoodBankService.' + method][index].result;
    };
  }));

  describe('logVisitController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller, fbHouseholdDetail) {
      scope = $rootScope.$new();
      settings = mockData('getAppSettings', 0);
      household = fbHouseholdDetail.translate(mockData('getHouseholdDetail', 0));
      ctrl = $controller('logVisitController', {
        $scope: scope, 
        foundSettings: settings,
        foundHousehold: household,
        fbLogVisit: {}
      });
    }));

    it('should have settings and household', function() {
      expect(scope.settings).toBeDefined();
      expect(scope.household.totalVisits).toBe(6);
    });
    
    xit('should validate form before saving', function() {

    });

    xit('should log a visit along with commodities and points used', function() {

    });
  });

});