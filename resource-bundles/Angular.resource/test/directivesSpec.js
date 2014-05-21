'use strict';

/* jasmine specs for directives go here */
/* global describe, beforeEach, it, xit, inject, expect, module, jasmine */

describe('directives', function() {
  
  beforeEach(module('foodBankApp'));

  describe('ngEnter', function() {
    var $compile;
    var $rootScope;
 
 
    // Store references to $rootScope and $compile
    // so they are available to all tests in this describe block
    beforeEach(inject(function(_$compile_, _$rootScope_){
      // The injector unwraps the underscores (_) from around the parameter names when matching
      $compile = _$compile_;
      $rootScope = _$rootScope_;
    }));
 
    xit('does something when enter key event arrives', function() {
        // Compile a piece of HTML containing the directive
        //var element = $compile("<a-great-eye></a-great-eye>")($rootScope);
        // fire all the watches, so the scope expression {{1 + 1}} will be evaluated
        //$rootScope.$digest();
        // Check that the compiled element contains the templated content
        //expect(element.html()).toContain("lidless, wreathed in flame, 2 times");
    });
  });

});