public with sharing class FoodBankHouseholds implements Database.Batchable<SObject>, Schedulable {

	@TestVisible
	private static integer MAX_NAMES_IN_HH_NAME = 2;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(
			[select Id, Name, Adults__c, Seniors__c, Children__c, Infants__c,
				(select Id, FirstName, LastName, Name, Age__c, Age_Entry_Date__c, Birthdate, AccountId, Gender__c, Id_Number__c from Contacts
					 order by createdDate, Age__c desc)
				from Account]);
	}

	public void execute(Database.BatchableContext BC, List<Account> batch) {
		list<Account> updatedHH = new list<Account>();
		for (Account hh : batch) {

			if (hh.Name != hh.Name) {
				hh.Name = hh.Name;

				updatedHH.add(hh);
			}
		}
		update updatedHH;
	}
	
	// Batch finish
	public void finish(Database.BatchableContext BC) {
	   // Nothing to do here.
	}

	public static void runBatchManually() {
		FoodBankHouseholds fbh = new FoodBankHouseholds();
		Database.executeBatch(fbh); 
	}
	
	public static void scheduleProcess(String schedule) {
		if (schedule == null) schedule = '0 0 1 * * ?';
		FoodBankHouseholds scheduler = new FoodBankHouseholds();
		System.schedule('FoodBankHouseholds', schedule, scheduler);
	}
	
	public void execute(SchedulableContext sc) {
		FoodBankHouseholds fbh = new FoodBankHouseholds();
		Database.executeBatch(fbh); 
	}
}