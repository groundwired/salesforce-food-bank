'use strict';
/* global describe, beforeEach, it, inject, expect, module, jasmine, Visualforce */

describe('client', function() {

  var $rootScope, mockData;
  var clientData = {
    'household':{
      'id':'a00i000000DzX4eAAF',
      'name':'Evan Callahan',
      'fullAddress':'3540 Quade Rd, Clinton, WA 98236',
      'totalVisits':6,
      'monthlyPointsAvailable':80,
      'tags':['No Cook','Spanish'],
      'address':'3540 Quade Rd',
      'city':'Clinton',
      'state':'WA',
      'postalCode':'98236',
      'phone':'(360) 555-1212',
      'notes':'Lorem ipsum dolor sit amet sunt mollit anim id est laborum.',
      'adults':1,
      'children':0,
      'infants':1,
      'seniors':0,
      'createdDate':1387437126000,
      'firstVisitDate':1326188100000,
      'mostRecentVisitDate':1466521048435,
      'proofOfAddressDate':1466348248435,
      'proofOfAddress':'ejc',
      'inactive':false,
      'totalMembers':2,
      'members':[
        {'id':'a02i000000A9AYPAA3',
          'name':'Evan Callahan',
          'firstName':'Evan',
          'lastName':'Callahan',
          'ageGroup':'Adult',
          'age':48,
          'birthdate':-123984000000},
        {'id':'a02i000000A9AYXAA3',
        'name':'Baby Callahan',
        'firstName':'Baby',
        'lastName':'Callahan',
        'ageGroup':'Infant',
        'age':1}
      ],
      'commodityUsage':{},
      'visitsThisMonth':0
    },
    'visits':[],
    'memberList':[
      {'memberData':{'id':'a02i000000A9AYPAA3',
      'name':'Evan Callahan',
      'firstName':'Evan',
      'lastName':'Callahan',
      'ageGroup':'Adult',
      'age':48,
      'birthdate':-123984000000}},
      {'memberData':{'id':'a02i000000A9AYXAA3',
      'name':'Baby Callahan',
      'firstName':'Baby',
      'lastName':'Callahan',
      'ageGroup':'Infant',
      'age':1}}
    ]
  };
    
  var settingsData = {
    'boxes':[{'Name':'Small','Id':'a05i000000AQtoeAAD','Minimum_Family_Size__c':1},{'Name':'Large','Id':'a05i000000AQtojAAD','Minimum_Family_Size__c':3},{'Name':'Extra-Large','Id':'a05i000000AQtooAAD','Minimum_Family_Size__c':4},{'Name':'No Cook','Id':'a05i000000AQtotAAD'}],
    'commodities':[{'Name':'Chili','Id':'a04i00000095u5IAAQ','Allow_Overage__c':false,'Monthly_Limit__c':3},{'Name':'Chicken','Id':'a04i00000095u5NAAQ','Allow_Overage__c':false,'Monthly_Limit__c':2},{'Name':'Ground Beef','Id':'a04i00000098ADOAA2','Allow_Overage__c':false,'Monthly_Limit__c':3},{'Name':'Toilet Paper','Id':'a04i000000BjhkoAAB','Allow_Overage__c':false,'Monthly_Limit__c':2},{'Name':'Paper Towels','Id':'a04i000000BjhkjAAB','Allow_Overage__c':false,'Monthly_Limit__c':1}],
    'general':{'Proof_of_Address_Update_Interval__c':12,'Check_in_Required__c':true,'Visit_Frequency_Limit__c':'Biweekly','LastModifiedById':'005i000000256L7AAI','Track_Points__c':false,'Monthly_Base_Points__c':70,'LastModifiedDate':1387495440000,'Allow_Overage__c':false,'Allow_Box_Size_Override__c':false,'Name':'a03i0000008CrsF','Monthly_Points_Per_Adult__c':10,'SetupOwnerId':'00Di0000000icjVEAQ','Welcome_Alert__c':'Please give your feedback on our new paperless food bank tracking system. Thank you for your cooperation as we try to serve you better.','Welcome_Message__c':'Welcome to Good Cheer!','Monthly_Points_Per_Child__c':10,'SystemModstamp':1387495440000,'Require_Unique_Address__c':true,'CreatedById':'005i000000256L7AAI','CreatedDate':1387495440000,'IsDeleted':false,'Id':'a03i0000008CrsFAAS','Proof_of_Address_Required__c':true,'Proof_of_Infant_Required__c':true,'Tags__c':'Special Diet; No Cook;Spanish; Vietnamese;Thai'}
  };

  beforeEach(module('foodBankApp'));
  beforeEach(inject(function(_$rootScope_) {
    $rootScope = _$rootScope_;
    $rootScope.status = {};
    $rootScope.data = clientData;
    $rootScope.settings = settingsData;

    // TODO: need to feed the data through the filter
    mockData = function(method, index) {
      return Visualforce.remoting.mockData['FoodBankManager.' + method][index].result;
    };
  }));

  describe('clientController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller, fbHouseholdDetail) {
      scope = $rootScope.$new();
      settings = mockData('getAppSettings', 0);
      household = fbHouseholdDetail.translate(mockData('getHouseholdDetail', 0));
      ctrl = $controller('clientController', {
        $scope: scope, 
        foundSettings: settings,
        foundHousehold: household
      });
    }));

    it('should have settings and household', function() {
      expect(scope.settings).toBeDefined();
      expect(scope.data.household.totalVisits).toBe(6);
      expect(scope.data.memberList.length).toBe(2);
    });
  });

  describe('addressController', function(){
    var ctrl, scope;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      ctrl = $controller('addressController', {
        $scope: scope, 
        fbSaveHousehold: {}
      });
    }));

    it('should initialize', function() {
      expect(scope.status.editingAddress).toBe(false);
    });

    it('should edit and save address', function() {
      scope.editAddress();
      expect(scope.status.editingAddress).toBe(true);
    });
  });
  
  describe('tagsController', function(){
    var ctrl, scope;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      ctrl = $controller('tagsController', {
        $scope: scope, 
        fbSaveHousehold: {}
      });
    }));

    it('should do something', function() {
      expect(true).toBe(true);
    });
  });
  
  describe('memberListController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      ctrl = $controller('memberListController', {
        $scope: scope, 
        basePath: '',
        fbSaveHouseholdMembers: {}
      });
    }));

    it('should do something', function() {
      expect(true).toBe(true);
    });
  });
  
  describe('notesController', function(){
    var ctrl, scope, settings, household;

    beforeEach(inject(function($controller) {
      scope = $rootScope.$new();
      ctrl = $controller('notesController', {
        $scope: scope, 
        fbSaveHousehold: {}
      });
    }));

    it('should do something', function() {
      expect(true).toBe(true);
    });
  });
});