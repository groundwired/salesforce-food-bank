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

	@isTest
	private static void testVisitTrigger() {

		Client_Household__c hh = new Client_Household__c();
		insert hh;

		Client_Visit__c cv = new Client_Visit__c(Household__c = hh.id);
		insert cv;


	}
}