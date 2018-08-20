'use strict';
/*global _*/
/*global moment*/

Object.defineProperties(Date, {
  MIN_VALUE: {
    value: -8640000000000000 // A number, not a date
  },
  MAX_VALUE: {
    value: 8640000000000000
  },
  MIN_BIRTHDATE: {
    value: new Date("1/1/1800").getTime()
  }
});

angular.module('appServices', ['appServerData']);

/* Javascript Remoting Service */
angular.module('appServices')
  .factory('jsRemoting', ['$q', '$rootScope', 'controllerName',
  function($q, $rootScope, controllerName) {
    return {
      // must provide method and the right number of arguments - other arguments are optional
      invoke: function( method, args, filterFunction, options ) {
        var deferred = $q.defer();

        // set defaults for remoting options
        var vfOptions = { buffer: true, escape: false, timeout: 20000 };
        _.extend( vfOptions, options );

        // set up required arguments: method, callback, options
        var allArgs = [
          controllerName + '.' + method,
          function(result, event) {
            $rootScope.$apply(function() {
              if (event.status) {

                // apply optional filter function to the results
                if (filterFunction !== undefined) {
                  result = filterFunction(result);
                }
                deferred.resolve(result);
              } else {
                // need to check for server disconnect
                if (!navigator.onLine || !event.message || event.message.indexOf('Unable to connect to the server') >= 0) {
                  $rootScope.$broadcast('alert:offline', event);
                } else if (event.message.indexOf('Invalid session') >= 0 ||
                           event.message.indexOf('Error parsing json response') >= 0 ||
                           event.message.indexOf('Remoting request invalid for your session') >= 0) {
                  $rootScope.$broadcast('alert:nosession', event);
                }
                deferred.reject(event);
              }
            });
          },
          vfOptions
        ];

        // add in the arguments provided for this remote action
        if ( _.isArray( args ) ) {
          _.forEach( args, function(v, i) {
            allArgs.splice(i + 1, 0, v);
          });
        } else if (args !== undefined) {
          allArgs.splice(1, 0, args);
        }

        // call out to visualforce
        /* global Visualforce */
        Visualforce.remoting.Manager.invokeAction.apply(
          Visualforce.remoting.Manager, allArgs
        );
        return deferred.promise;
      }
    };
  }]);


/* Remoting data methods */

angular.module('appServices')
  .factory('fbCustomLabel', ['jsRemoting', function(jsRemoting) {
    return {
      get : function( label ) {
        return jsRemoting.invoke('getCustomLabel', label);
      }
    };
  }]);

angular.module('appServices')
  .factory('fbCheckInList', ['jsRemoting', function(jsRemoting) {
    return {
      get : function() {
        return jsRemoting.invoke('getCheckedInList');
      }
    };
  }]);

angular.module('appServices')
  .factory('fbStats', ['jsRemoting', function(jsRemoting) {
    return {
      get : function( timeframe ) {
        return jsRemoting.invoke('getStats', timeframe);
      }
    };
  }]);

angular.module('appServices')
  .factory('fbHouseholdSearch', ['jsRemoting', function(jsRemoting) {
    return {
      get : function( query ) { //, includeInactive ) {
        return jsRemoting.invoke('queryHouseholds', query); //, includeInactive]);
      }
    };
  }]);

angular.module('appServices')
  .factory('fbSettings', ['$q', 'jsRemoting', function($q, jsRemoting) {
    var settings = {};
    return {
      get : function() {
        if (settings && settings.general) {
          var deferred = $q.defer();
          deferred.resolve(settings);
          return deferred.promise;
        } else {
          return jsRemoting.invoke('getAppSettings', [], this.translate);
        }
      },
      translate : function(result) {
        settings.general = {};
        settings.general.allowBoxSizeOverride = result.general.Allow_Box_Size_Override__c;
        settings.general.allowOverage = result.general.Allow_Overage__c;
        settings.general.checkInRequired = result.general.Check_in_Required__c;
        settings.general.monthlyBasePoints = result.general.Monthly_Base_Points__c;
        settings.general.monthlyPointsPerAdult = result.general.Monthly_Points_Per_Adult__c;
        settings.general.monthlyPointsPerChild = result.general.Monthly_Points_Per_Child__c;
        settings.general.monthlyVisitLimit = result.general.Monthly_Visit_Limit__c;
        settings.general.proofOfAddressRequired = result.general.Proof_of_Address_Required__c;
        settings.general.proofOfAddressUpdateInterval = result.general.Proof_of_Address_Update_Interval__c;
        settings.general.requireUniqueAddress = result.general.Require_Unique_Address__c;
        settings.general.showIdNumber = result.general.Show_Id__c;
        settings.general.proofOfInfantRequired = result.general.Proof_of_Infant_Required__c;
        settings.general.trackCheckoutWeight = result.general.Track_Checkout_Weight__c;
        settings.general.trackPoints = result.general.Track_Points__c;
        settings.general.visitFrequencyLimit = result.general.Visit_Frequency_Limit__c;
        settings.general.weeklyVisitLimit = result.general.Weekly_Visit_Limit__c;
        settings.general.welcomeAlert = result.general.Welcome_Alert__c;
        settings.general.welcomeMessage = result.general.Welcome_Message__c;

        settings.tags = (result.general.Tags__c) ? (_.map(result.general.Tags__c.split(';'), _.trim)) : [];

        settings.commodities = [];
        _.forEach(result.commodities, function(c){
          settings.commodities.push({
            'name': c.Name,
            'allowOverage': c.Allow_Overage__c,
            'monthlyLimit': c.Monthly_Limit__c
          });
        });

        settings.boxes = [];
        _.forEach(result.boxes, function(c){
          settings.boxes.push({
            'name': c.Name,
            'minimumFamilySize': c.Minimum_Family_Size__c
          });
        });

        return settings;
      }
    };
  }]);

angular.module('appServices')
  .factory('fbHouseholdDetail', ['jsRemoting', 'fbSettings',
  function(jsRemoting, fbSettings) {
    var sdo = {
      get : function( hhid ) {
        return jsRemoting.invoke('getHouseholdDetail', hhid, this.translate);
      },
      getSObject: function( hh ) {
        var sobj = {
          Name: hh.name,
          Total_Visits__c: hh.totalVisits,
          Monthly_Points_Available__c: hh.monthlyPointsAvailable,
          Tags__c: hh.tags ? hh.tags.join(';') : undefined,
          BillingStreet: hh.address,
          BillingCity: hh.city,
          BillingState: hh.state,
          BillingPostalCode: hh.postalCode,
          Phone: hh.phone,
          Homeless__c: hh.homeless,
          Out_Of_Area__c: hh.outofarea,
          Notes__c: hh.notes,
          Source__c: hh.source,
          External_ID__c: hh.externalId,
          Adults__c: hh.adults,
          Children__c: hh.children,
          Infants__c: hh.infants,
          Seniors__c: hh.seniors,
          CreatedDate: hh.createdDate,
          First_Visit__c: hh.firstVisitDate,
          Most_Recent_Visit__c: hh.mostRecentVisitDate,
          Proof_of_Address__c: hh.proofOfAddress,
          Inactive__c: hh.inactive,
          Pending_Commodity_Usage_JSON__c: hh.Pending_Commodity_Usage_JSON__c,
          Pending_Notes__c: hh.Pending_Notes__c
        };
        if (hh.id) sobj.Id = hh.id;
        return sobj;
      },

      getMemberSObject : function( mobj ) {
        var sobj = {
          FirstName: mobj.firstName,
          LastName: mobj.lastName,
          Age_Group__c: mobj.ageGroup,
          Id_Number__c: mobj.Id_Number,
          Gender__c: mobj.gender,
          Age__c: mobj.age,
          birthdate: (mobj.birthdate) ? mobj.birthdate.getTime() : Date.MIN_BIRTHDATE,
          Proof_of_Infant__c: mobj.proofOfInfant
        };
        if (mobj.id) sobj.Id = mobj.id;
        return sobj;
      },

      translate : function( result ) {
        var client = {
          id: result.Id,
          name: result.Name,
          fullAddress: String.format('{0}, {1}, {2} {3}', 
            (result.BillingStreet != null) ? result.BillingStreet : '',
            (result.BillingCity != null) ? result.BillingCity : '',
            (result.BillingState != null) ? result.BillingState : '',
            (result.BillingPostalCode != null) ? result.BillingPostalCode : ''),
          totalVisits: result.Total_Visits__c,
          monthlyPointsAvailable: result.Monthly_Points_Available__c,
          tags: (result.Tags__c) ? (_.map(result.Tags__c.split(';'), _.trim)) : null,
          address: result.BillingStreet,
          city: result.BillingCity,
          state: result.BillingState,
          postalCode: result.BillingPostalCode,
          phone: result.Phone,
          homeless: result.Homeless__c,
          outofarea: result.Out_Of_Area__c,
          notes: result.Notes__c,
          source: result.Source__c,
          externalId: result.External_ID__c,
          adults: result.Adults__c,
          children: result.Children__c,
          infants: result.Infants__c,
          seniors: result.Seniors__c,
          createdDate: result.CreatedDate,
          firstVisitDate: result.First_Visit__c,
          mostRecentVisitDate: result.Most_Recent_Visit__c,
          proofOfAddressDate: result.Proof_of_Address_Date__c,
          proofOfAddress: result.Proof_of_Address__c,
          inactive: result.Inactive__c,
          pendingcommodityusage: result.Pending_Commodity_Usage_JSON__c,
          pendingnotes: result.Pending_Notes__c
        };

        // add up the household members
        if (!client.adults) { client.adults = 0; }
        if (!client.seniors) { client.seniors = 0; }
        if (!client.children) { client.children = 0; }
        if (!client.infants) { client.infants = 0; }
        client.totalMembers = client.adults + client.seniors + client.children + client.infants;

        // build list of members
        client.members = [];
        _.forEach( result.Contacts, function(v) {
          client.members.push({
            id: v.Id,
            name: v.Name,
            firstName: v.FirstName,
            lastName: v.LastName,
            ageGroup: v.Age_Group__c,
            Id_Number: v.Id_Number__c,
            gender: v.Gender__c,
            age: v.Age__c,
            // v.Birthdate + 12 hours to make sure rounding to correct day since Date parses the value as GMT then converts to Browser Time Zone (Pacific)
            birthdate: (v.Birthdate) ? new Date(v.Birthdate + (12 * 60 * 60 * 1000)) : Date.MIN_BIRTHDATE,
            proofOfInfant: v.Proof_of_Infant__c
          });
        });

        // add up points and commodities used in previous visits this month
        var pointsUsed = 0;
        client.commodityUsage = {};
        client.visitsThisMonth = (result.Visits__r ? result.Visits__r.length : 0);
        _.forEach( result.Visits__r, function(v) {
          if (v.Points_Used__c) {
            pointsUsed += v.Points_Used__c;
          }

          // TODO: try catch? json could be bogus
          if (v.Commodity_Usage_JSON__c) {
            _.forEach( angular.fromJson( v.Commodity_Usage_JSON__c ), function(v, k) {
              if (k in client.commodityUsage) {
                client.commodityUsage[k] += v;
              } else {
                client.commodityUsage[k] = v;
              }
            });
          }
        });

        // Check the checkin queue for pending commodities
        client.commodityPending = {};
        if (client.pendingcommodityusage != null) {
          _.forEach( angular.fromJson( client.pendingcommodityusage ), function(v, k) {
              client.commodityPending[k] = v;
          });
        }

        // subtract commodity usage to get the current available commodities
        fbSettings.get().then(
          function(settings){
            client.commodityAvailability = [];
            _.forEach( settings.commodities, function(v) {
              var comm = v;
              comm.ptsUsed = 0;
              if( client.commodityPending && (v.name in client.commodityPending) ) {
                comm.ptsUsed = client.commodityPending[v.name];
              }
              comm.remaining = comm.monthlyLimit;
              if( client.commodityUsage && (v.name in client.commodityUsage) ) {
                comm.remaining -= client.commodityUsage[v.name];
              }
              client.commodityAvailability.push(comm);
            });

            // TODO: add a box override
            // figure which box this client gets
            client.defaultBox = '';
            _.forEach( settings.boxes, function(v) {
              if (client.defaultBox === '' ||
                  (v.minimumFamilySize && v.minimumFamilySize <= client.totalMembers)) {
                client.defaultBox = v.name;
              }
            });

            // do we need proof of address?
            if (settings.general.proofOfAddressRequired) {

              var proofOfAddressCutoffDate =
                (settings.general.proofOfAddressUpdateInterval == null) ? null :
                moment().subtract(settings.general.proofOfAddressUpdateInterval, 'months');

              var proofOfAddressNeeded =
                (!proofOfAddressCutoffDate || client.proofOfAddressDate == undefined ||
                  moment(client.proofOfAddressDate).isBefore(proofOfAddressCutoffDate));

              // if the proof is old, clear it out
              if (proofOfAddressNeeded) {
                client.proofOfAddress = null;
              }
            }
            
            if (settings.general.trackPoints) {
              client.currentPointsUsed = pointsUsed;
              client.currentPointsRemaining = client.monthlyPointsAvailable - pointsUsed;              
            }
          }
        );
        return client;
      }
    };
    
    return sdo;
  }]);

angular.module('appServices')
  .factory('fbSaveHousehold', ['jsRemoting', 'fbHouseholdDetail', function(jsRemoting, fbHouseholdDetail) {
    return function( hh ) {
      if ( hh ) {
        return jsRemoting.invoke('saveHousehold', [fbHouseholdDetail.getSObject(hh)], fbHouseholdDetail.translate);
      } else {
        return;  // need to return a promise, i think
      }
    };
  }]);

angular.module('appServices')
  .factory('fbSaveHouseholdMembers', ['jsRemoting', 'fbHouseholdDetail', function(jsRemoting, fbHouseholdDetail) {
    return function( hhid, members ) {
      var memberList = _.map(members, fbHouseholdDetail.getMemberSObject);
      return jsRemoting.invoke('saveHouseholdMembers', [hhid, memberList], fbHouseholdDetail.translate);
    };
  }]);

angular.module('appServices')
  .factory('fbSaveHouseholdAndMembers', ['jsRemoting', 'fbHouseholdDetail', function(jsRemoting, fbHouseholdDetail) {
    return function( hh, members ) {
      var memberList = _.map(members, fbHouseholdDetail.getMemberSObject);
      return jsRemoting.invoke('saveHouseholdAndMembers', [fbHouseholdDetail.getSObject(hh), memberList], fbHouseholdDetail.translate);
    };
  }]);

angular.module('appServices')
  .factory('fbCheckIn', ['jsRemoting', function(jsRemoting) {
      return function( hhid, contactid, commodities, notes ) {
        return jsRemoting.invoke('checkIn', [hhid, contactid, commodities, notes]);
      };
  }]);

angular.module('appServices')
  .factory('fbVisitHistory', ['jsRemoting', function(jsRemoting) {
    return function( hhid ) {
      return jsRemoting.invoke('getVisitHistory', hhid, function(result){
        var visits = [];
        _.forEach(result, function(result){
          visits.push({
            'date': result.Visit_Date__c,
            'visitor': (result.Visitor__r) ? result.Visitor__r.Name : '',
            'boxType': result.Box_Type__c,
            'ptsUsed': result.Points_Used__c,
            'checkoutWeight' : result.Checkout_Weight__c,
            'notes': result.Notes__c
          });
        });
        return visits;
      });
    };
  }]);

angular.module('appServices')
  .factory('fbCancelCheckIn', ['jsRemoting', function(jsRemoting) {
    return function( hhid ) {
      return jsRemoting.invoke('cancelCheckIn', hhid);
    };
  }]);

angular.module('appServices')
  .factory('fbLogVisit', ['jsRemoting', function(jsRemoting) {
    return function( hhid, contactid, boxType, checkoutWeight, pointsUsed, commodities, notes ) {
      return jsRemoting.invoke('logVisit', [hhid, contactid, boxType, checkoutWeight, pointsUsed, commodities, notes]);
    };
  }]);
