'use strict';

/*
** Purpose of this file is to provide a stub for our angular module that
** provides base resource path and Visualforce Remoting data to the app
*/
angular.module('appServerData', [])
  .constant('basePath', '')
  .constant('controllerName', 'FoodBankManager');

/**
* Stub for our angular module, provides base resource path and mocks 
* the Visualforce Javascript Remoting and Remote Objects data services
*/

// works just like Javascript Remoting!
var Visualforce = {
  remoting: {
    // sample data to be returned for each javascript remoting method
    mockData: {
      'FoodBankManager.getAppSettings': [
        { result: {"boxes":[{"Name":"Small","Id":"a05i000000AQtoeAAD","Minimum_Family_Size__c":1},{"Name":"Large","Id":"a05i000000AQtojAAD","Minimum_Family_Size__c":3},{"Name":"Extra-Large","Id":"a05i000000AQtooAAD","Minimum_Family_Size__c":4},{"Name":"No Cook","Id":"a05i000000AQtotAAD"}],"commodities":[{"Name":"Chili","Id":"a04i00000095u5IAAQ","Allow_Overage__c":false,"Monthly_Limit__c":3},{"Name":"Chicken","Id":"a04i00000095u5NAAQ","Allow_Overage__c":false,"Monthly_Limit__c":2},{"Name":"Ground Beef","Id":"a04i00000098ADOAA2","Allow_Overage__c":false,"Monthly_Limit__c":3},{"Name":"Toilet Paper","Id":"a04i000000BjhkoAAB","Allow_Overage__c":false,"Monthly_Limit__c":2},{"Name":"Paper Towels","Id":"a04i000000BjhkjAAB","Allow_Overage__c":false,"Monthly_Limit__c":1}],"general":{"Proof_of_Address_Update_Interval__c":12,"LastModifiedById":"005i000000256L7AAI","Track_Points__c":true,"Monthly_Base_Points__c":70,"LastModifiedDate":1387495440000,"Allow_Overage__c":false,"Allow_Box_Size_Override__c":false,"Name":"a03i0000008CrsF","Monthly_Points_Per_Adult__c":10,"SetupOwnerId":"00Di0000000icjVEAQ","Welcome_Alert__c":"Please give your feedback on our new paperless food bank tracking system. Thank you for your cooperation as we try to serve you better.","Welcome_Message__c":"Welcome to Good Cheer!","Monthly_Points_Per_Child__c":10,"SystemModstamp":1387495440000,"Require_Unique_Address__c":true,"CreatedById":"005i000000256L7AAI","CreatedDate":1387495440000,"IsDeleted":false,"Id":"a03i0000008CrsFAAS","Proof_of_Address_Required__c":true, "Tags__c": "Special Diet; No Cook;Spanish; Vietnamese;Thai"}} }
      ],
      'FoodBankManager.getStats': [
        /* error result */
        { args: ["simulate-no-session"], error: "Invalid session.  Re-login and retry." },
        /* default result */
        { result: {"adults":[257,126,383],"boxTotals":{},"children":[137,68,205],"hhVisits":[189,133,322],"homeless":[14,5,19],"infants":[8,2,10],"onePerson":[79,56,135],"overOnePerson":[110,77,187],"pointsUsed":8,"seniors":[60,95,155],"total":[462,291,753]}  }
      ],
      'FoodBankManager.getCheckedInList': [
        { result: [{"checkinNotToday":true,"checkInTime":1394865903000,"clientId":"a00i000000DzX4eAAF","clientName":"Evan Callahan","pointsRemaining":72}] }
      ],
      'FoodBankManager.queryHouseholds': [
        { result: [{"addr":"3540 Quade Rd, Clinton, WA 98236","id":"a00i000000DzX4eAAF","name":"Evan Callahan","value":"Evan Callahan (3540 Quade Rd)"},{"addr":"Homeless, Langley, WA 98260","id":"a00i000000GOrlsAAD","name":"J J and B Evans","value":"J J and B Evans (Homeless)"},{"addr":"1334 Bercot Rd., Freeland, WA 98236","id":"a00i000000GOrjSAAT","name":"Jason, Jr and Evan Smith","value":"Jason, Jr and Evan Smith (1334 Plumcot Rd.)"}]  }
      ],
      'FoodBankManager.getHouseholdDetail': [
        { result: {"Client_Names__c":"Evan Callahan","Adults__c":1,"Notes__c":"Lorem ipsum dolor sit amet, consectetur elit, sed do sic eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","Full_Address__c":"3540 Quade Rd, Clinton, WA 98236","Total_Visits__c":6,"Postal_Code__c":"98236","LastModifiedDate":1394728892000,"Seniors__c":0,"Infants__c":0,"Phone__c":"(360) 555-1212","Name":"HH-000001","City__c":"Clinton","Monthly_Points_Available__c":80,"Inactive__c":false,"Address__c":"3540 Quade Rd","Clients__r":[{"Name":"Evan Callahan","First_Name__c":"Evan","Last_Name__c":"Callahan","Client_Household__c":"a00i000000DzX4eAAF","Age_Group__c":"Adult","Age__c":48,"Id":"a02i000000A9AYPAA3","Birthdate__c":-123984000000}],"Children__c":0,"CreatedDate":1387437126000,"First_Visit__c":1326188100000,"State__c":"WA","Id":"a00i000000DzX4eAAF","Most_Recent_Visit__c":1394444971000,"Tags__c":"No Cook; Spanish"} }
      ],
      'FoodBankManager.checkIn': [ { result: { } } ],
      'FoodBankManager.cancelCheckIn': [ { result: { } } ],
      'FoodBankManager.saveHousehold': [
        { result: {"Client_Names__c":"Evan Callahan","Adults__c":1,"Notes__c":"Lorem ipsum dolor sit amet, consectetur elit, sed do sic eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","Full_Address__c":"3540 Quade Road, Clinton, WA 98236","Total_Visits__c":6,"Postal_Code__c":"98236","LastModifiedDate":1394728892000,"Seniors__c":0,"Infants__c":0,"Phone__c":"(360) 555-1212","Name":"HH-000001","City__c":"Clinton","Monthly_Points_Available__c":80,"Inactive__c":false,"Address__c":"3540 Quade Road","Clients__r":[{"Name":"Evan Callahan","First_Name__c":"Evan","Last_Name__c":"Callahan","Client_Household__c":"a00i000000DzX4eAAF","Age_Group__c":"Adult","Age__c":48,"Id":"a02i000000A9AYPAA3","Birthdate__c":-123984000000}],"Children__c":0,"CreatedDate":1387437126000,"First_Visit__c":1326188100000,"State__c":"WA","Id":"a00i000000DzX4eAAF","Most_Recent_Visit__c":1394444971000,"Tags__c":"No Cook; Spanish"} }
      ],
      'FoodBankManager.saveHouseholdMembers': [
        { result: {"Client_Names__c":"Evan Callahan","Adults__c":1,"Notes__c":"Lorem ipsum dolor sit amet, consectetur elit, sed do sic eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","Full_Address__c":"3540 Quade Rd, Clinton, WA 98236","Total_Visits__c":6,"Postal_Code__c":"98236","LastModifiedDate":1394728892000,"Seniors__c":0,"Infants__c":0,"Phone__c":"(360) 555-1212","Name":"HH-000001","City__c":"Clinton","Monthly_Points_Available__c":80,"Inactive__c":false,"Address__c":"3540 Quade Rd","Clients__r":[{"Name":"Evan Callahan","First_Name__c":"Evan","Last_Name__c":"Callahan","Client_Household__c":"a00i000000DzX4eAAF","Age_Group__c":"Adult","Age__c":49,"Id":"a02i000000A9AYPAA3","Birthdate__c":-123984000000}],"Children__c":0,"CreatedDate":1387437126000,"First_Visit__c":1326188100000,"State__c":"WA","Id":"a00i000000DzX4eAAF","Most_Recent_Visit__c":1394444971000,"Tags__c":"No Cook; Spanish"} }
      ],
      'FoodBankManager.saveHouseholdAndMembers': [ { result: { } } ],
      'FoodBankManager.logVisit':  [ { result: { } } ],
      'FoodBankManager.getVisitHistory': [
        { result: [{"Points_Used__c":1,"Visit_Date__c":1400474328000,"Notes__c":"Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ","Id":"a01i000000Gqdt4AAB"},{"Points_Used__c":60,"Visit_Date__c":1400363517000,"Id":"a01i000000Gq32vAAB"},{"Points_Used__c":5,"Visit_Date__c":1400363291000,"Id":"a01i000000Gq30GAAR"},{"Points_Used__c":4,"Visit_Date__c":1326188100000,"Notes__c":"This is a test.","Id":"a01i0000009FS2vAAG"}] }
      ]
    }
  }
};
var JavascriptRemotingMock = function(){};
JavascriptRemotingMock.prototype.invokeAction = function() {
  var args = Array.prototype.slice.call(arguments, 0),
    methodName = args.shift(),
    i = args.length - 1,
    cb;

  if (_.isFunction( args[i] )) {
    cb = args.pop();
  } else if (_.isFunction( args[--i] )) {
    args.pop();
    cb = args.pop();
  }
  var result;
  var event;
  var mdr = Visualforce.remoting.mockData[methodName];
  if (_.isUndefined( mdr )) {
    throw new Error('No data for remoting method: ' + methodName);
  } else {
    if ( !_.isArray(mdr) ) {
      mdr = [ mdr ];
    }
    _.forEach( mdr, function(obj) {
      if ( _.isUndefined( event ) && ( _.isUndefined(obj.args) || _.isEqual( args, obj.args ) )) {
        if ( obj.error ) {
          event = new Error( obj.error );
        } else {
          result = obj.result;
          event = { status: true };
        }
      }
    });
  }
  setTimeout(function(){
    cb.call(this, result, event);
  }, 0);
};
Visualforce.remoting.Manager = new JavascriptRemotingMock();
