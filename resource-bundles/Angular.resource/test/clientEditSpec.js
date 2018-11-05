'use strict';
/* global describe, beforeEach, it, inject, expect, module, jasmine, Visualforce */

describe('client_edit', function() {

  var $rootScope, mockData;

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_) {
    $rootScope = _$rootScope_;

    mockData = function(method, index) {
      return Visualforce.remoting.mockData['FoodBankService.' + method][index].result;
    };
  }));

  describe('clentEditController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller, fbHouseholdDetail, fbSettings) {
      scope = $rootScope.$new();
      settings = fbSettings.translate(mockData('getAppSettings', 0));
      household = fbHouseholdDetail.translate(mockData('getHouseholdDetail', 0));
      ctrl = $controller('clientEditController', {
        $scope: scope, 
        foundSettings: settings,
        foundHousehold: household,
        basePath: '',
        fbSaveHouseholdAndMembers: {}
      });
    }));

    it('should have settings', function() {
      expect(scope.settings).toBeDefined();
    });

    xit('should update tags', function() {

    });

    xit('should add and delete members', function() {

    });
    
    xit('should validate form before saving', function() {

    });

    xit('should save client and members', function() {

    });
  });

});