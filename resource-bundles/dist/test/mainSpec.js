'use strict';
/* global describe, beforeEach, it, inject, expect, module, jasmine */

describe('main', function() {

  beforeEach(module('foodBankApp'));

  describe('mainController', function(){
    var scope, ctrl;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      ctrl = $controller('mainController', {$scope: scope});
    }));

    it('should set base path and status', function() {
      expect(scope.basePath).toBe('');
      expect(scope.status.loading).toBe(false);
    });
  });

});