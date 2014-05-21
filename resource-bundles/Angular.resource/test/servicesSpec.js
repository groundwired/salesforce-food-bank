'use strict';

/* jasmine specs for services go here */
/* global describe, beforeEach, afterEach, it, inject, expect, module, jasmine */

describe('services', function() {

  beforeEach(module('foodBankApp'));

  describe('fbSettings', function() {
    var svc, rootScope;
    beforeEach(inject(function(fbSettings, $rootScope) {
      svc = fbSettings;
      rootScope = $rootScope;
      jasmine.clock().install();
    }));

    it('should get settings', function() {
      var vfs;
      svc.get().then( function(result) {
        vfs = result;
      });
      /* wait for timeout so promise gets resolved */
      jasmine.clock().tick(1);
      expect(vfs).toBeDefined();
      expect(vfs.general).toBeDefined();
    });

    afterEach(function() {
      jasmine.clock().uninstall();
    });
  });

});
