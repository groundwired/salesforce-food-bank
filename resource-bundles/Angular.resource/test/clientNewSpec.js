'use strict';
/* global describe, beforeEach, it, inject, expect, module, jasmine, Visualforce */

describe('client_new', function() {

  var $rootScope, mockData;

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_) {
    $rootScope = _$rootScope_;

    mockData = function(method, index) {
      return Visualforce.remoting.mockData['FoodBankManager.' + method][index].result;
    };
  }));

  describe('clentEditController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller, fbSettings) {
      scope = $rootScope.$new();
      settings = fbSettings.translate(mockData('getAppSettings', 0));
      household = {name: 'Doe Household', members: [{ firstName: 'John Doe', lastName: 'John Doe' }]};
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
      expect(scope.data.tagsData).toBeDefined();
    });

    xit('should add and delete members', function() {

    });
    
    xit('should validate form before saving', function() {

    });

    xit('should save client and members', function() {

    });
  });

});