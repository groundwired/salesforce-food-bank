'use strict';
/* global _ */

/* Angular app definition */

angular.module('foodBankApp', [
  'ngRoute',
  'ngCookies',
  'ngAnimate',
  'ui.bootstrap',
  'mgcrea.ngStrap.alert',
  'appServerData',
  'appServices',
  'appDirectives',
  'mainController',
  'homeController',
  'clientController',
  'clientEditController',
  'logVisitController'
])
  .config(['$alertProvider', function($alertProvider) {
    _.extend($alertProvider.defaults, {
      container: '.alertContainer'
    });
  }])
  .config(['$routeProvider', 'basePath', function($routeProvider, basePath) {
    $routeProvider
      .when('/', {
        templateUrl: basePath + '/app/home/home.html',
        controller: 'homeController',
        resolve: {
          foundSettings: function(fbSettings) {
            return fbSettings.get();
          }
        }
      })
      .when('/client/:clientId/:clientContactId/:action?', {
        templateUrl: basePath + '/app/client/client.html',
        controller: 'clientController',
        resolve: {
          foundSettings: function(fbSettings) {
            return fbSettings.get();
          },
          foundHousehold: function(fbHouseholdDetail, $route) {
            return fbHouseholdDetail.get($route.current.params.clientId);
          }
        }
      })
      .when('/edit_client/:clientId/:action?', {
        templateUrl: basePath + '/app/client_edit/client_edit.html',
        controller: 'clientEditController',
        resolve: {
          foundSettings: function(fbSettings) {
            return fbSettings.get();
          },
          foundHousehold: function(fbHouseholdDetail, $route) {
            return fbHouseholdDetail.get($route.current.params.clientId);
          }
        }
      })
      .when('/new_client/', {
        templateUrl: basePath + '/app/client_edit/client_edit.html',
        controller: 'clientEditController',
        resolve: {
          foundSettings: function(fbSettings) {
            return fbSettings.get();
          },
          foundHousehold: function($q, $route) {
            var deferred = $q.defer();
            deferred.resolve({name: 'Unknown', members: [{ firstName: ''}]});
            return deferred.promise;
          }
        }
      })
      .when('/log_visit/:clientId/:clientContactId', {
        templateUrl: basePath + '/app/log_visit/log_visit.html',
        controller: 'logVisitController',
        resolve: {
          foundSettings: function(fbSettings) {
            return fbSettings.get();
          },
          foundHousehold: function(fbHouseholdDetail, $route) {
            return fbHouseholdDetail.get($route.current.params.clientId);
          }
        }
      })
      .otherwise({redirectTo: '/'});
  }]);