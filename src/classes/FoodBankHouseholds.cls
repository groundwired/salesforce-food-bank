public with sharing class FoodBankHouseholds implements Database.Batchable<SObject>, Schedulable {

	private static integer MAX_NAMES_IN_HH_NAME = 2;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(
			[select Id, Full_Address__c, Client_Names__c, Adults__c, Seniors__c, Children__c, Infants__c,
				(select Id, First_Name__c, Last_Name__c, Name, Age__c, Age_Entry_Date__c, Birthdate__c, Client_Household__c from Clients__r
					 order by createdDate, Age__c desc)
				from Client_Household__c]);
	}

	public void execute(Database.BatchableContext BC, List<Client_Household__c> batch) {
		list<Client_Household__c> updatedHH = new list<Client_Household__c>();
		for (Client_Household__c hh : batch) {
			String n = calculateHHName( hh, hh.Clients__r );
			if (hh.Client_Names__c != n) {
				hh.Client_Names__c = n;
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

	public static String calculateHHName( Client_Household__c hh, list<Client__c> members ) {
		if ( members == null ) return hh.full_address__c;
		
		list<Client__c> adultMembers = new list<Client__c>();
		for ( Client__c cl : members )
			if ( (cl.Age__c == null || cl.Age__c >= 18) && (MAX_NAMES_IN_HH_NAME == null || adultMembers.size() < MAX_NAMES_IN_HH_NAME) )
				adultMembers.add( cl );

		// if there are no adults, name the household as if the children were adults
		if ( adultMembers.size() == 0 ) {
			adultMembers = members;
		}

		if ( adultMembers.size() == 1 ) {
			return adultMembers[0].Name;
		} else {
			list<String> lastNames = new list<String>();
			map<String, list<String>> lastToFirstNames = new map<String, list<String>>();
			for ( Client__c cl : adultMembers ) {
				if (!lastToFirstNames.containsKey(cl.Last_Name__c)) {
					lastNames.add(cl.Last_Name__c);
					lastToFirstNames.put(cl.Last_Name__c, new list<String>());
				}
				if (cl.First_Name__c != null)
					lastToFirstNames.get(cl.Last_Name__c).add(cl.First_Name__c);
			}
			String hhName = '';
			for ( String lname : lastNames ) {
				String fnames = String.join(lastToFirstNames.get( lname ), ' and ');
				hhName += ((hhName.length() > 0) ? ' and ' : '') + fnames + ' ' + lname;
			}
			return hhName;
		}
	}
}