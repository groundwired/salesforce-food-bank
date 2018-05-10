@isTest
public with sharing class FoodBankTriggerTest {

	@isTest
	private static void testClientTrigger() {
		Account hh = new Account(
            Name = 'Test Account'
		);
		insert hh;

		Contact c = new Contact( AccountId = hh.id, LastName = 'Test', Birthdate = system.today().addyears(-50) );
		insert c;

		Contact c1 = [select id, age__c, name, Account.Name from Contact where id =: c.id];
		//system.assertEquals('Test', c1.name );
		//system.assertEquals('Test', c1.Account.Name );
		//system.assertEquals(50, c1.age__c ); 

		c.FirstName = 'Jane';
		c.Birthdate = system.today().addyears(-45);
		update c;

		Contact c2 = [select id, age__c, name, Account.Name from Contact where id =: c.id];
		//system.assertEquals('Jane Test', c2.name );
		//system.assertEquals('Jane Test', c2.Account.Name );	
		//system.assertEquals(45, c2.age__c );

		Contact c3 = new Contact(  AccountId = hh.id, FirstName = 'Bob', LastName = 'Test', age__c = 40 );
		insert c3;

		Contact c4 = [select id, age__c, name, Account.Name from Contact where id =: c3.id];
		//system.assertEquals('Bob Test', c4.name );
		//system.assertEquals('Jane and Bob Test', c4.Account.Name );
		//system.assertEquals(40, c4.age__c );

		Contact c5 = new Contact(  AccountId = hh.id, FirstName = 'Peter', LastName = 'Test', age__c = 5 );
		Contact c6 = new Contact(  AccountId = hh.id, FirstName = 'Andrew', LastName = 'Testy' );
		insert new list<Contact>{ c5, c6 };

		Contact c7 = [select id, age__c, name, Account.Name, Account.adults__c, Account.children__c
							from Contact where id =: c6.id];
		//system.assertEquals('Andrew Testy', c7.name );
		//system.assertEquals('Jane and Bob Test', c7.Account.Name );
		//system.assertEquals(3, c7.Account.adults__c );
		//system.assertEquals(1, c7.Account.children__c );

		delete new list<Contact>{ c4, c5 };

		Contact c8 = [select id, age__c, name, Account.Name, Account.adults__c, Account.children__c 
							from Contact where id =: c1.id];
		//system.assertEquals('Jane Test', c8.name );
		//system.assertEquals('Jane Test and Andrew Testy', c8.Account.Name );		
		//system.assertEquals(2, c8.Account.adults__c );
		//system.assertEquals(0, c8.Account.children__c );
	}

	@isTest static void testChangeProofOfAddress() {
		Account household = new Account(
			Name = 'Test Account',
			BillingStreet = '123 Main Street',
            BillingCity = 'Seattle',
            BillingState = 'WA',
            BillingPostalCode = '98103',
            Proof_of_Address__c = 'Utility bill',
            Proof_of_Address_Date__c = System.today().addYears(-2)
		);
        insert household;

        household.Proof_of_Address__c = 'Staff verified - JS';
        update household;

        household = [ SELECT Proof_of_Address_Date__c FROM Account WHERE Id = :household.Id ];

        //system.assertEquals(System.today(), household.Proof_of_Address_Date__c, 'Proof of Address date should update to current date');
	}

	@isTest static void testupdateContactAge() {
		Account household = new Account(
            Name = 'Test Account'
		);
        insert household;

        Contact c1 = new Contact(
        	AccountId = household.Id, 
        	FirstName = 'Amber', 
        	LastName = 'Smith', 
        	Age__c = 55
        ); 
        insert c1;

        c1.Age__c = 55;
        c1.Age_Entry_Date__c = System.today().addYears(-2);
        update c1;

        c1 = [ SELECT Age__c, Age_Entry_Date__c FROM Contact WHERE Id = :c1.Id ];
        //system.assertEquals(57, c1.Age__c, 'If age was 55 and was entered 2 years ago, age should be recalculated to 57');

	}

	@isTest
	private static void testVisitTrigger() {

		Boolean todayIsJan1 = (System.today().month() == 1 && System.today().day() == 1);
		Integer dateOffset = (todayIsJan1 ? -1 : 0);

		Account hh = new Account(
            Name = 'Test Account'
		);
		insert hh;

		Client_Visit__c cv = new Client_Visit__c(Household__c = hh.id, Visit_Date__c = System.today().addDays(dateOffset - 1));
		insert cv;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		//system.assertEquals(true, cv.First_Visit_This_Year__c);

		Client_Visit__c cv2 = new Client_Visit__c(Household__c = hh.id, Visit_Date__c = System.today().addDays(dateOffset));
		insert cv2;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		//system.assertEquals(true, cv.First_Visit_This_Year__c);

		cv2 = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv2.Id ];
		//system.assertEquals(todayIsJan1, cv2.First_Visit_This_Year__c);
	}

	@isTest
	private static void testVisitTriggerNoDates() {

		Account hh = new Account(
            Name = 'Test Account'
		);
		insert hh;

		Client_Visit__c cv = new Client_Visit__c(Household__c = hh.id);
		insert cv;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		//system.assertEquals(true, cv.First_Visit_This_Year__c);

		Client_Visit__c cv2 = new Client_Visit__c(Household__c = hh.id);
		insert cv2;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		cv2 = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv2.Id ];
		//system.assertEquals(true, cv.First_Visit_This_Year__c);
		//system.assertEquals(false, cv2.First_Visit_This_Year__c);
	}
}