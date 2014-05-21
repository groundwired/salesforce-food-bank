@isTest
public with sharing class FoodBankStatsTest {

	@isTest
	private static void testFoodBankStats() {
		FoodBankStats fbs = new FoodBankStats();
		fbs.loadStats();
		fbs.queryStats('TODAY');
	}

}