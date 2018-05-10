@isTest
private class FoodBankHouseholdsTest {
    
    // there are no adult client names
    @isTest static void testNoAdultNames() {
        Account household = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main Street',
            BillingCity = 'Seattle',
            BillingState = 'WA',
            BillingPostalCode = '98103'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 12));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Amber Smith', household.Name, 'If there are no adult clients, treat the children as adults.');
    }

    // there's just one person
    @isTest static void testSingleName() {
        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Amber Smith', household.Name, 'Household name should match client name when there\'s only one person');
    }

    // there's just one person with just a last name
    @isTest static void testSingleNameLastNameOnly() {
        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, null, 'Smith', 57));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Smith', household.Name, 'Household name should match client name when there\'s only one person and first name is missing');
    }

    // last names match
    @isTest static void testMatchingLastNames() {
        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        clients.add(createClient(household.Id, 'Joe', 'Smith', 55));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Amber and Joe Smith', household.Name, 'Name should be combined when last names match');
    }
    
    // last names don't match
    @isTest static void testNonMatchingLastNames() {
        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, 'Amber', 'Smith', 57));
        clients.add(createClient(household.Id, 'Joe', 'Burns', 55));
        insert clients;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Amber Smith and Joe Burns', household.Name, 'Name should not be combined when last names don\'t match');
    }

    // more than max number of names
    @isTest static void testSeveralLastNames() {
        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
        clients.add(createClient(household.Id, 'Joe', 'Burns', 88));
        clients.add(createClient(household.Id, 'Patty', 'Freeman', 8));
        clients.add(createClient(household.Id, 'Amber', 'Smith', 12));
        clients.add(createClient(household.Id, 'David', 'Gonzalez', 55));
        insert clients;

        // this is the default value; assume that's what we're testing against
        FoodBankHouseholds.MAX_NAMES_IN_HH_NAME = 2;

        FoodBankHouseholds.runBatchManually();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Joe Burns and David Gonzalez', household.Name, 'Only the names of the two adults should be used');
    }

    // test scheduled job
    @isTest static void testScheduleHHUpdate() {

        Account household = new Account(
            Name = 'Test Account'
        );
        insert household;

        List<Contact> clients = new List<Contact>();
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

        //System.assertEquals(0, ct.TimesTriggered, 'Job should not have run yet');
        //System.assertEquals('2099-03-15 00:00:00', String.valueOf(ct.NextFireTime), 'Next run should match time from cron expression');
        
        Test.stopTest();

        household = [ SELECT Name FROM Account WHERE Id = :household.Id ];
        //System.assertEquals('Amber and Joe Smith', household.Name, 'Name should not be set yet');
 
    }
    
    private static Contact createClient(Id householdId, String firstName, String lastName, Integer age) {
        Contact client = new Contact( 
            AccountId = householdId, 
            FirstName = firstName,
            LastName = lastName, 
            Birthdate = System.today().addyears(-age)
        );
        return client;
    }
    
}