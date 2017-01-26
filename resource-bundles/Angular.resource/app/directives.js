'use strict';

/* Directives */

angular.module('appDirectives', []);

angular.module('appDirectives')
  .directive('ngEnter', function() {
    return function (scope, element, attrs) {
      element.bind('keydown keypress', function (event) {
        if(event.which === 13) {
          scope.$apply(function () {
            scope.$eval(attrs.ngEnter);
          });
          event.preventDefault();
        }
      });
    };
  });

angular.module('appDirectives')
  .directive('ngSetfocus', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        scope.$watch( function() {
          return scope.$eval(attrs.ngSetfocus);
        }, function (newValue) {
          if (newValue === true) {
            element[0].focus();
          }
        });
      }
    };
  });
