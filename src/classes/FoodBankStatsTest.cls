@isTest
public with sharing class FoodBankStatsTest {

	@isTest
	private static void testFoodBankStats() {

		// insert a household and a visit for today
        Client_Household__c hh = new Client_Household__c( Inactive__c = false );
        hh = FoodBankManager.saveHousehold(hh);
        Map<String, Integer> commU = new Map<String, Integer>();
        Id cVId = FoodBankManager.logVisit(hh.Id, 'Big', 5, commU, 'These are notes');

		ApexPages.CurrentPage().getParameters().put('tfcode','TODAY');
		FoodBankStats fbs = new FoodBankStats();
		fbs.loadStats();
		fbs.queryStats('TODAY');
	}

}