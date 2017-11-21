@isTest
public with sharing class FoodBankTriggerTest {

	@isTest
	private static void testClientTrigger() {
		Client_Household__c hh = new Client_Household__c();
		insert hh;

		Client__c c = new Client__c( Client_Household__c = hh.id, last_name__c = 'Test', birthdate__c = system.today().addyears(-50) );
		insert c;

		Client__c c1 = [select id, age__c, name, client_household__r.client_names__c from Client__c where id =: c.id];
		system.assertEquals('Test', c1.name );
		system.assertEquals('Test', c1.client_household__r.client_names__c );
		system.assertEquals(50, c1.age__c ); 

		c.first_name__c = 'Jane';
		c.birthdate__c = system.today().addyears(-45);
		update c;

		Client__c c2 = [select id, age__c, name, client_household__r.client_names__c from Client__c where id =: c.id];
		system.assertEquals('Jane Test', c2.name );
		system.assertEquals('Jane Test', c2.client_household__r.client_names__c );	
		system.assertEquals(45, c2.age__c );

		Client__c c3 = new Client__c(  Client_Household__c = hh.id, name = 'Bob Test', age__c = 40 );
		insert c3;

		Client__c c4 = [select id, age__c, name, client_household__r.client_names__c from Client__c where id =: c3.id];
		system.assertEquals('Bob Test', c4.name );
		system.assertEquals('Jane and Bob Test', c4.client_household__r.client_names__c );
		system.assertEquals(40, c4.age__c );

		Client__c c5 = new Client__c(  Client_Household__c = hh.id, first_name__c = 'Peter', last_name__c = 'Test', age__c = 5 );
		Client__c c6 = new Client__c(  Client_Household__c = hh.id, first_name__c = 'Andrew', last_name__c = 'Testy' );
		insert new list<Client__c>{ c5, c6 };

		Client__c c7 = [select id, age__c, name, client_household__r.client_names__c, client_household__r.adults__c, client_household__r.children__c
							from Client__c where id =: c6.id];
		system.assertEquals('Andrew Testy', c7.name );
		system.assertEquals('Jane and Bob Test', c7.client_household__r.client_names__c );
		system.assertEquals(3, c7.client_household__r.adults__c );
		system.assertEquals(1, c7.client_household__r.children__c );

		delete new list<Client__c>{ c4, c5 };

		Client__c c8 = [select id, age__c, name, client_household__r.client_names__c, client_household__r.adults__c, client_household__r.children__c 
							from Client__c where id =: c1.id];
		system.assertEquals('Jane Test', c8.name );
		system.assertEquals('Jane Test and Andrew Testy', c8.client_household__r.client_names__c );		
		system.assertEquals(2, c8.client_household__r.adults__c );
		system.assertEquals(0, c8.client_household__r.children__c );
	}

	@isTest static void testChangeProofOfAddress() {
		Client_Household__c household = new Client_Household__c(
			Address__c = '123 Main Street',
            City__c = 'Seattle',
            State__c = 'WA',
            Postal_Code__c = '98103',
            Proof_of_Address__c = 'Utility bill',
            Proof_of_Address_Date__c = System.today().addYears(-2)
		);
        insert household;

        household.Proof_of_Address__c = 'Staff verified - JS';
        update household;

        household = [ SELECT Proof_of_Address_Date__c FROM Client_Household__c WHERE Id = :household.Id ];

        System.assertEquals(System.today(), household.Proof_of_Address_Date__c, 'Proof of Address date should update to current date');
	}

	@isTest static void testUpdateClientAge() {
		Client_Household__c household = new Client_Household__c();
        insert household;

        Client__c c1 = new Client__c(
        	Client_Household__c = household.Id, 
        	Name = 'Amber Smith', 
        	Age__c = 55
        ); 
        insert c1;

        c1.Age__c = 55;
        c1.Age_Entry_Date__c = System.today().addYears(-2);
        update c1;

        c1 = [ SELECT Age__c, Age_Entry_Date__c FROM Client__c WHERE Id = :c1.Id ];
        System.assertEquals(57, c1.Age__c, 'If age was 55 and was entered 2 years ago, age should be recalculated to 57');

	}

	@isTest
	private static void testVisitTrigger() {

		Boolean todayIsJan1 = (System.today().month() == 1 && System.today().day() == 1);
		Integer dateOffset = (todayIsJan1 ? -1 : 0);

		Client_Household__c hh = new Client_Household__c();
		insert hh;

		Client_Visit__c cv = new Client_Visit__c(Household__c = hh.id, Visit_Date__c = System.today().addDays(dateOffset - 1));
		insert cv;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		System.assertEquals(true, cv.First_Visit_This_Year__c);

		Client_Visit__c cv2 = new Client_Visit__c(Household__c = hh.id, Visit_Date__c = System.today().addDays(dateOffset));
		insert cv2;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		System.assertEquals(true, cv.First_Visit_This_Year__c);

		cv2 = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv2.Id ];
		System.assertEquals(todayIsJan1, cv2.First_Visit_This_Year__c);
	}

	@isTest
	private static void testVisitTriggerNoDates() {

		Client_Household__c hh = new Client_Household__c();
		insert hh;

		Client_Visit__c cv = new Client_Visit__c(Household__c = hh.id);
		insert cv;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		System.assertEquals(true, cv.First_Visit_This_Year__c);

		Client_Visit__c cv2 = new Client_Visit__c(Household__c = hh.id);
		insert cv2;

		cv = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv.Id ];
		cv2 = [ SELECT First_Visit_This_Year__c FROM Client_Visit__c WHERE Id = :cv2.Id ];
		System.assertEquals(true, cv.First_Visit_This_Year__c);
		System.assertEquals(false, cv2.First_Visit_This_Year__c);
	}
}