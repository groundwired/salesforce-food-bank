@isTest
public with sharing class FoodBankStatsTest {

	@isTest
	private static void testFoodBankStats() {

		// insert a household and a visit for today
        Account hh = new Account(
			Name = 'Test Account',
			Inactive__c = false
			);

		// insert a contact
        Contact contact = new Contact(
			Lastname = 'Test Lastname'
			);

        hh = FoodBankService.saveHousehold(hh);

		Food_Bank_Checkin__c checkin1 = new Food_Bank_Checkin__c(
			Name = hh.Id,
            Points_Remaining__c = 15,
            Box_Size__c = 'small',
            Check_In_Time__c = Datetime.now()
        );

		insert checkin1;
		
        Map<String, Integer> commU = new Map<String, Integer>();
        Id cVId = FoodBankService.logVisit(hh.Id, contact.Id, 'small', 1.5, 5, commU, 'These are notes');

		ApexPages.CurrentPage().getParameters().put('tfcode','TODAY');
		FoodBankStats fbs = new FoodBankStats();
		fbs.loadStats();
		fbs.queryStats('TODAY');
	}

}