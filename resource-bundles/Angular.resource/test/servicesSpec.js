'use strict';

/* jasmine specs for services go here */
/* global describe, beforeEach, afterEach, it, inject, expect, module, jasmine */

describe('services', function() {

  var rootScope;

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function($rootScope) {
    rootScope = $rootScope;
    jasmine.clock().install();
  }));

  describe('fbCheckInList', function() {
    var svc;
    beforeEach(inject(function(fbCheckInList) {
      svc = fbCheckInList;
    }));

    it('should get checkin list', function() {
      var resultData;
      svc.get().then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData[0].clientId).toBeDefined();
    });
  });

  describe('fbStats', function() {
    var svc;
    beforeEach(inject(function(fbStats) {
      svc = fbStats;
    }));

    it('should get statistics', function() {
      var resultData;
      svc.get().then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.hhVisits).toBeDefined();
      expect(resultData.hhVisits.length).toBe(3);
    });
  });

  describe('fbHouseholdSearch', function() {
    var svc;
    beforeEach(inject(function(fbHouseholdSearch) {
      svc = fbHouseholdSearch;
    }));

    it('should search households', function() {
      var resultData;
      svc.get('callahan').then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.length).toBe(3);
      expect(resultData[0].name).toBe('Evan Callahan');
    });
  });

  describe('fbSettings', function() {
    var svc;
    beforeEach(inject(function(fbSettings) {
      svc = fbSettings;
      jasmine.clock().install();
    }));

    it('should get settings', function() {
      var resultData;
      svc.get().then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.general).toBeDefined();
    });
  });

  describe('fbHouseholdDetail', function() {
    var svc;
    beforeEach(inject(function(fbHouseholdDetail) {
      svc = fbHouseholdDetail;
      jasmine.clock().install();
    }));

    it('should return a household', function() {
      var resultData;
      svc.get('some-household-id').then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.totalVisits).toBeDefined();
      expect(resultData.members).toBeDefined();
      expect(resultData.members.length).toBe(2);
      expect(resultData.members[0].name).toBe('Evan Callahan');
    });
  });
  
  describe('fbSaveHousehold', function() {
    var svc;
    beforeEach(inject(function(fbSaveHousehold) {
      svc = fbSaveHousehold;
      jasmine.clock().install();
    }));

    it('should save a household', function() {
      var resultData;
      var tstHH = {};
      svc( tstHH ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.totalVisits).toBeDefined();
      expect(resultData.members).toBeDefined();
      expect(resultData.members.length).toBe(2);
      expect(resultData.members[0].name).toBe('Evan Callahan');
    });
  });

  describe('fbSaveHouseholdMembers', function() {
    var svc;
    beforeEach(inject(function(fbSaveHouseholdMembers) {
      svc = fbSaveHouseholdMembers;
      jasmine.clock().install();
    }));

    it('should save household members', function() {
      var resultData;
      var tstMembers = [{}, {}];
      svc( 'some-household-id', tstMembers ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.totalVisits).toBeDefined();
      expect(resultData.members).toBeDefined();
      expect(resultData.members.length).toBe(2);
      expect(resultData.members[0].name).toBe('Evan Callahan');
    });
  });

  describe('fbSaveHouseholdAndMembers', function() {
    var svc;
    beforeEach(inject(function(fbSaveHouseholdAndMembers) {
      svc = fbSaveHouseholdAndMembers;
      jasmine.clock().install();
    }));

    it('should save a household and its members', function() {
      var resultData;
      var tstHH = {};
      var tstMembers = [{}, {}];
      svc( tstHH, tstMembers ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData.totalVisits).toBeDefined();
      expect(resultData.members).toBeDefined();
      expect(resultData.members.length).toBe(2);
      expect(resultData.members[0].name).toBe('Evan Callahan');
    });
  });

  describe('fbCheckIn', function() {
    var svc;
    beforeEach(inject(function(fbCheckIn) {
      svc = fbCheckIn;
      jasmine.clock().install();
    }));

    it('should check in a visitor', function() {
      var resultData;
      var tstVisit = {};
      svc( tstVisit ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
    });
  });

  describe('fbVisitHistory', function() {
    var svc;
    beforeEach(inject(function(fbVisitHistory) {
      svc = fbVisitHistory;
      jasmine.clock().install();
    }));

    it('should list visit history', function() {
      var resultData;
      svc( 'some-household-id' ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
      expect(resultData[0].date).toBeDefined();
    });
  });

  describe('fbCancelCheckIn', function() {
    var svc;
    beforeEach(inject(function(fbCancelCheckIn) {
      svc = fbCancelCheckIn;
      jasmine.clock().install();
    }));

    it('should cancel check in', function() {
      var resultData;
      svc( 'some-checkin-id' ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBeDefined();
    });
  });

  describe('fbLogVisit', function() {
    var svc;
    beforeEach(inject(function(fbLogVisit) {
      svc = fbLogVisit;
      jasmine.clock().install();
    }));

    it('should log a visit', function() {
      var resultData;
      var tstVisit = {};
      svc( tstVisit ).then( function(result) {
        resultData = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(resultData).toBe('a01i000000Gqdt4AAB');
    });
  });

  afterEach(function() {
    jasmine.clock().uninstall();
  });
});
