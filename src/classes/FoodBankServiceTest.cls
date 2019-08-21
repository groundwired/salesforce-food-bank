@isTest(SeeAllData=false)
public with sharing class FoodBankServiceTest {

    @isTest
    private static void testCheckOutIn() {
        // New Household insert then update
        Account cHh = new Account(
            Name = 'Test Account'
        );
        insert(cHh);

        // New contact nsert then update
        Contact cContact = new Contact(
            Lastname = 'Test Lastname'
        );
        insert(cContact);

        Map<String, Integer> commU = new Map<String, Integer>();
        commU.put('Meat', 2);
        commU.put('Bread', 1);

        // Test CheckIn & CheckOut
        FoodBankService.checkIn(cHh.Id, cContact.Id, commU, 'Notes', 'Food Bank', '01/01/2019', 'Unknown');
        System.assert(Food_Bank_Checkin__c.getInstance(cHh.Id) != null);

        // Attempt to CheckIn again should throw error
        try {
            FoodBankService.checkIn(cHh.Id, cContact.Id, commU, 'Notes', 'Food Bank', '01/01/2019', 'Unknown');
            System.assert(false, 'Error should have occured');
        } catch (Exception ex) {
            // Nothing to see here
            // TODO: check to see if correct error is thrown
        }

        FoodBankService.cancelCheckIn(cHh.Id);
        System.assert(Food_Bank_Checkin__c.getInstance(cHh.Id) == null);
    }

    @isTest
    private static void testSaveHouseHold() {
        Account cHh = new Account(
            Name = 'Test Account',
            Inactive__c = false
        );
        
        // Check insert of Household
        Account cHh0 = new Account(Name = 'Test Account');
        cHh0 = FoodBankService.saveHousehold(cHh);
        System.assert(cHh0.Id != null, 'Id should not be null');

        // Check update of Household
        cHh.BillingStreet = '101 1st St';
        cHh0 = FoodBankService.saveHousehold(cHh);
        System.assert(cHh0.BillingStreet == cHh.BillingStreet, 'Method did not update Household: ' + cHh0.Children__c);

        // Insert Client
        Contact c1 = new Contact( AccountId = null, LastName = 'Test1', Birthdate = System.today().addyears(-50) );
        cHh0 = FoodBankService.saveHouseholdMembers(cHh.Id, new List<Contact> { c1 });
        System.assert(cHh0.Name != null, 'Method did not update Household: ' + cHh0.Name);

        // Update Client
        c1.FirstName = 'Test2';
        cHh0 = FoodBankService.saveHouseholdMembers(cHh.Id, new List<Contact> { c1 });
        System.assert(cHh0.Name != null, 'Method did not update Household: ' + cHh0.Name);
        System.debug('***** Client Name: ' + cHh0.Name);
        System.debug('***** Inactive: ' + cHh0.Inactive__c);

        List<FoodBankService.ClientHousehold> cHs = FoodBankService.queryHouseholds(cHh0.Name);
// TODO     // System.assertEquals(1, cHs.size(), 'Could not find: ' + cHh0.Name);   

        // Save new Household and Client
        Account cHh1 = new Account(
            Name = 'Test Account'
        );
        Contact c2 = new Contact( AccountId = null, LastName = 'Test1', Birthdate = System.today().addyears(-50) );
        Account cHh2 = FoodBankService.saveHouseholdAndMembers(cHh1, new List<Contact> { c2 });       
        System.assert(cHh2.Id != null, 'Id should not be null');
        
        FoodBankService.AppSettings appSettings = FoodBankService.getAppSettings();
        System.assert(appSettings.general != null);
    }


	@isTest
	private static void testCheckInsVisits() {
		Account household1 = new Account(
            Name = 'Test Account',
			Inactive__c = false
		);
		
		// Check insert of Household
		household1 = FoodBankService.saveHousehold(household1);

		// insert a contact
        Contact contact = new Contact(
			Lastname = 'Test Lastname',
            AccountId = household1.Id
			);
        insert contact;

		Food_Bank_Checkin__c checkin1 = new Food_Bank_Checkin__c(
			Name = household1.Id,
			Visitor__c = contact.Id,
            Points_Remaining__c = 15,
            Box_Size__c = 'small',
            Check_In_Time__c = Datetime.now()
        );

		insert checkin1;

		Account household2 = new Account(
            Name = 'Test Account',
			Inactive__c = false
		);
		
		// Check insert of Household
		household2 = FoodBankService.saveHousehold(household2);

		Food_Bank_Checkin__c checkin2 = new Food_Bank_Checkin__c(
			Name = household2.Id,
			Visitor__c = contact.Id,
            Points_Remaining__c = 15,
            Box_Size__c = 'small',
            Check_In_Time__c = Datetime.now()
        );
		insert checkin2;

		List<FoodBankService.ClientCheckin> cc = FoodBankService.getCheckedInList();
		System.assertEquals(2, cc.size(), 'Two households are currently checked in');

		Map<String, Integer> commU = new Map<String, Integer>();
		commU.put('Meat', 2);
		commU.put('Bread', 1);
		Id cVId = FoodBankService.logVisit(household1.Id, contact.Id, 'small', 1.1, 5, commU, 'These are notes');
		System.assert(cVId != null);

		List<Food_Bank_Visit__c> cV = FoodBankService.getVisitHistory(household1.Id);
		System.assert(cV.size() == 1);	
	}	
    
}