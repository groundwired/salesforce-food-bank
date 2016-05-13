@isTest
private class FoodBankHouseholdsTest {
    
    // there are no adult client names
    @isTest static void testNoAdultNames() {
        Client_Household__c household = new Client_Household__c(
            Address__c = '123 Main Street',
            City__c = 'Seattle',
            State__c = 'WA',
            Postal_Code__c = '98103'
        );
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 12));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Full_Address__c, Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals(household.Full_Address__c, household.Client_Names__c, 'If there are no adult clients, Client Names should match Full Address');
    }

    // there's just one person
    @isTest static void testSingleName() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Amber Smith', household.Client_Names__c, 'Household name should match client name when there\'s only one person');
    }

    // names have changed
    @isTest static void testRecalculateName() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        insert clients;

        household.Client_Names__c = 'Something else';
        update household;

        System.assertEquals('Something else', household.Client_Names__c);

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Amber Smith', household.Client_Names__c, 'Household name should match client name when there\'s only one person');
    }

    // there's just one person with just a last name
    @isTest static void testSingleNameLastNameOnly() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, null, 'Smith', 57));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Smith', household.Client_Names__c, 'Household name should match client name when there\'s only one person and first name is missing');
    }

    // last names match
    @isTest static void testMatchingLastNames() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        clients.add(createClient(household.Id, 'Joe', 'Smith', 55));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Amber and Joe Smith', household.Client_Names__c, 'Name should be combined when last names match');
    }
    
    // last names don't match
    @isTest static void testNonMatchingLastNames() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        clients.add(createClient(household.Id, 'Joe', 'Burns', 55));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Amber Smith and Joe Burns', household.Client_Names__c, 'Name should not be combined when last names don\'t match');
    }

    // more than max number of names
    @isTest static void testSeveralLastNames() {
        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Joe', 'Burns', 88));
        clients.add(createClient(household.Id, 'Patty', 'Freeman', 8));
        clients.add(createClient(household.Id, 'Amber', 'Smith', 12));
        clients.add(createClient(household.Id, 'David', 'Gonzalez', 55));
        insert clients;

        // this is the default value; assume that's what we're testing against
        FoodBankHouseholds.MAX_NAMES_IN_HH_NAME = 2;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Joe Burns and David Gonzalez', household.Client_Names__c, 'Only the names of the two adults should be used');
    }

    // test scheduled job
    @isTest static void testScheduleHHUpdate() {

        Client_Household__c household = new Client_Household__c();
        insert household;

        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        clients.add(createClient(household.Id, 'Joe', 'Smith', 55));
        insert clients;

        Test.startTest();

        String cron = '0 0 0 15 3 ? 2099';

        FoodBankHouseholds.scheduleProcess(cron);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE CronExpression = :cron];

        System.assertEquals(0, ct.TimesTriggered, 'Job should not have run yet');
        System.assertEquals('2099-03-15 00:00:00', String.valueOf(ct.NextFireTime), 'Next run should match time from cron expression');
        
        Test.stopTest();

        household = [ SELECT Client_Names__c FROM Client_Household__c WHERE Id = :household.Id ];
        System.assertEquals('Amber and Joe Smith', household.Client_Names__c, 'Name should not be set yet');
 
    }
    
    private static Client__c createClient(Id householdId, String firstName, String lastName, Integer age) {
        Client__c client = new Client__c( 
            Client_Household__c = householdId, 
            First_Name__c = firstName,
            Last_Name__c = lastName, 
            Birthdate__c = System.today().addyears(-age)
        );
        return client;
    }
	
}