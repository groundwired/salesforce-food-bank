'use strict';
/* global describe, beforeEach, it, inject, expect, module, jasmine, Visualforce */

describe('client', function() {

  var $rootScope, settingsData, householdData;
  
  var mockData = function(method, index) {
    return Visualforce.remoting.mockData['FoodBankService.' + method][index].result;
  };
  
  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_, fbHouseholdDetail, fbSettings) {
    
    settingsData = fbSettings.translate(mockData('getAppSettings', 0));
    householdData = fbHouseholdDetail.translate(mockData('getHouseholdDetail', 0));
    
    $rootScope = _$rootScope_;
    $rootScope.settings = settingsData;
    $rootScope.status = {};
    $rootScope.data = {
      'household': householdData,
      'visits':[],
      'memberList':[]
    };    
  }));

  describe('clientController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      
      household = householdData;
      ctrl = $controller('clientController', {
        $scope: scope, 
        foundSettings: settingsData,
        foundHousehold: householdData
      });
    }));

    it('should have settings and household', function() {
      expect(scope.settings).toBeDefined();
      expect(scope.data.household.totalVisits).toBe(6);
      expect(scope.data.memberList.length).toBe(2);
    });

    xit('should set points', function() {
      
    });

    xit('should set commodities', function() {
      
    });

    xit('should report whether there is an infant', function() {
      
    });

    xit('should report that infant proof is required', function() {
      
    });

    xit('should not warn if the client has not visited recently', function() {
      
    });

    xit('should warn if the client has visited too recently', function() {
      
    });

    xit('should be able to edit and cancel editing', function() {
      
    });
    
    xit('should validate form before saving', function() {

    });

    xit('should save all sections of the form', function() {
      
    });

    xit('should check the client in', function() {
      
    });

    xit('should record a visit', function() {
      
    });

    xit('should query for visits', function() {
      
    });

  });

  describe('addressController', function(){
    var ctrl, scope, fbSaveHousehold;

    beforeEach(inject(function($controller, _$q_) {
      scope = $rootScope.$new();
      ctrl = $controller('addressController', {
        $scope: scope, 
        fbSaveHousehold: function() { 
          var deferred = _$q_.defer();
          deferred.resolve( householdData );
          return deferred.promise;
        }
      });      
    }));

    it('should edit and save address', function() {
      // eventListener = jasmine.createSpy();
      // spyOn(window, "FileReader").and.returnValue({
      
      expect(scope.data.household.city).toBe('Clinton');
      expect(scope.status.editingAddress).toBe(false);
      scope.editAddress();
      expect(scope.status.editingAddress).toBe(true);
      expect(scope.data.addressData.city).toBe('Clinton');
      scope.data.addressData.city = 'Seattle';
      scope.saveAddress();
      $rootScope.$apply();
      expect(scope.status.editingAddress).toBe(false);
      
      // expect(eventListener.calls.mostRecent().args[0]).toEqual('loadend');
    });
  });
  
  describe('tagsController', function(){
    var ctrl, scope;

    beforeEach(inject(function($controller, _$q_) {
      scope = $rootScope.$new();
      ctrl = $controller('tagsController', {
        $scope: scope, 
        fbSaveHousehold: function() { 
          var deferred = _$q_.defer();
          deferred.resolve( householdData );
          return deferred.promise;
        }
      });
    }));

    it('should edit and save tags', function() {
      expect(scope.tagDropdown.options.length).toBe(5);
      expect(scope.tagDropdown.selected.length).toBe(2);
      scope.editTags();
      expect(scope.status.editingTags).toBe(true);
      scope.updateTags();
      scope.saveTags();
      expect(scope.status.savingTags).toBe(true);
      $rootScope.$apply();
      expect(scope.status.savingTags).toBe(false);
      expect(scope.status.editingTags).toBe(false);
    });

    it('should add tag to the list', function() {
      expect(scope.tagDropdown.options.length).toBe(5);
      expect(scope.tagDropdown.selected.length).toBe(2);
      expect(scope.data.household.tags.length).toBe(2);
      expect(scope.data.tagsData.tags.length).toBe(2);
      scope.editTags();
      scope.tagDropdown.selected.push({id: 'Vietnamese', label: 'Vietnamese'});
      expect(scope.data.tagsData.tags.length).toBe(2);
      scope.updateTags();
      expect(scope.data.tagsData.tags.length).toBe(3);
      scope.saveTags();
      $rootScope.$apply();
    });

    it('should remove a tag from the list', function() {
      expect(scope.tagDropdown.options.length).toBe(5);
      expect(scope.tagDropdown.selected.length).toBe(2);
      expect(scope.data.household.tags.length).toBe(2);
      expect(scope.data.tagsData.tags.length).toBe(2);
      scope.editTags();
      scope.tagDropdown.selected.pop();
      expect(scope.data.tagsData.tags.length).toBe(2);
      scope.updateTags();
      expect(scope.data.tagsData.tags.length).toBe(1);
      scope.saveTags();
      $rootScope.$apply();
    });

    it('should cancel tag edits', function() {
      scope.editTags();
      expect(scope.status.editingTags).toBe(true);
      scope.tagDropdown.selected.push({id: 'Vietnamese', label: 'Vietnamese'});
      scope.updateTags();
      expect(scope.data.tagsData.tags.length).toBe(3);
      scope.cancelTags();
      expect(scope.data.tagsData.tags.length).toBe(2);
    });
  });
  
  describe('memberListController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller, _$q_) {
      scope = $rootScope.$new();
      ctrl = $controller('memberListController', {
        $scope: scope, 
        basePath: '',
        fbSaveHouseholdMembers: function() { 
          var deferred = _$q_.defer();
          deferred.resolve( householdData );
          return deferred.promise;
        }
      });
    }));

    it('should edit and save members', function() {
      expect(scope.status.editingMembers).toBe(false);
      scope.editMembers();
      expect(scope.status.editingMembers).toBe(true);
      scope.saveMembers();
      expect(scope.status.savingMembers).toBe(true);
      $rootScope.$apply();
      expect(scope.status.savingMembers).toBe(false);
      expect(scope.status.editingMembers).toBe(false);
    });

    xit('should add a member to the list', function() {
      
    });

    xit('should delete a member from the list', function() {
      
    });

    xit('should cancel member edits', function() {
      
    });

  });
  
  describe('notesController', function(){
    var ctrl, scope;

    beforeEach(inject(function($controller, _$q_) {
      scope = $rootScope.$new();
      ctrl = $controller('notesController', {
        $scope: scope, 
        fbSaveHousehold: function() { 
          var deferred = _$q_.defer();
          deferred.resolve( householdData );
          return deferred.promise;
        }
      });      
    }));

    it('should edit and save notes', function() {
      expect(scope.status.editingNotes).toBe(false);
      scope.editNotes();
      expect(scope.status.editingNotes).toBe(true);
      expect(scope.data.household.notes).toBeDefined();
      scope.data.household.notes = 'New notes';
      scope.saveNotes();
      expect(scope.status.savingNotes).toBe(true);
      $rootScope.$apply();
      expect(scope.status.savingNotes).toBe(false);
      expect(scope.status.editingNotes).toBe(false);
    });
  });
});