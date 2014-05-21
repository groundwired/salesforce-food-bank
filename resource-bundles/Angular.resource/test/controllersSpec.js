'use strict';

/* jasmine specs for controllers go here */
/* global describe, beforeEach, it, inject, expect, module, jasmine */

describe('controllers', function() {

  beforeEach(module('foodBankApp'));

  describe('mainController', function(){
    var scope, ctrl;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      ctrl = $controller('mainController', {$scope: scope});
    }));

    it('should set partial path', function() {
      expect(scope.pathTo('file.html')).toBe('/file.html');
    });
  });

});