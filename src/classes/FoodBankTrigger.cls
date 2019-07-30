public with sharing class FoodBankTrigger {

	// only need one instance of this class per transaction
	private static FoodBankTrigger instance;
	public static FoodBankTrigger get() {
		if (instance == null) instance = new FoodBankTrigger();
		return instance;
	}

	private static Boolean nowUpdatingVisitCheckbox = false;

	public void updateProofDates( list<Account> hhList, map<id, Account> oldMap ) {

		// set the proof of address date
		for (Account hh : hhList) {
			if (String.isBlank(hh.Proof_of_Address__c)) {
				hh.Proof_of_Address_Date__c = null;
			} else {
				if (oldMap == null || hh.Proof_of_Address__c != oldMap.get(hh.id).Proof_of_Address__c ) {
					hh.Proof_of_Address_Date__c = system.today();
				}
			}
		}
	}

	public void updateContactAge( list<Contact> clientList, map<id, Contact> oldMap ) {

		for ( Contact c : clientList ) {

			// if we have a birthdate, use it to set the age
			if ( c.Birthdate != null && getAge( c.Birthdate ) >= 0 ) {
				c.Age__c = getAge( c.Birthdate );
				c.Age_Entry_Date__c = null;

			// if age just got set, set age entry date
			} else if ( c.Age__c != null && ( oldMap == null || c.Age__c != oldMap.get(c.Id).Age__c ) ) {
				c.Age_Entry_Date__c = system.today();

			// if age entry date is over 1 year ago, update age and age entry date
			} else if ( c.Age__c != null && c.Age_Entry_Date__c != null ) {
				while ( c.Age_Entry_Date__c <= system.today().addYears(-1) ) {
					c.Age__c += 1;
					c.Age_Entry_Date__c = c.Age_Entry_Date__c.addYears(1);
				}
			}
		}
	}

	private Integer getAge( Date birthdate ) {
		Integer yrs = system.today().year() - birthdate.year();

		// if it isn't your birthday yet, you are one year younger
		if (system.today().month() < birthdate.month() || 
				(system.today().month() == birthdate.month() && system.today().day() < birthdate.day())) 
			yrs -= 1;

		return (yrs > 199) ? -1 : yrs;
	}

	// after trigger to maintain household record based on client changes
	public void fixHouseholdForContactChange( list<Contact> clientList, map<id, Contact> oldMap, Boolean isDelete ) {

		map<id, list<Contact>> triggerHHMap = new map<id, list<Contact>>();
		
		if ( clientList != null ) {
			// collect all the households and clients in the trigger set
			for ( Contact c : clientList ) {
				if (!triggerHHMap.containsKey(c.AccountId)) {
					triggerHHMap.put(c.AccountId, new list<Contact>{ c });
				} else {
					triggerHHMap.get(c.AccountId).add(c);
				}
			}
		}

		// fix the household client names field as needed
		list<Account> hhToUpdate = new list<Account>();

		for ( Account hh : 
				[select Id, Name, Adults__c, Seniors__c, Children__c, Infants__c,
					(select Id, Name, FirstName, LastName, Age__c, Age_Entry_Date__c, Birthdate, 
						AccountId, Id_Number__c, Inactive__c from Contacts
						where Id not in : clientList order by createdDate, Id, Age__c desc)
					from Account where id in : triggerHHMap.keyset()] ) {

			list<Contact> allMembers = new list<Contact>();
			for ( Contact c : hh.Contacts )
				allMembers.add( c );

			// may need to fix ages of clients we query for (if they have an expired age and no birthdate)
			updateContactAgeIfOlder( allMembers ); 

			//TODO: should sort these into the list by create date to avoid reshuffling
			if (!isDelete) {
				for (Contact c : triggerHHMap.get( hh.Id ) )
					allMembers.add( c );
			}

			Account newHH = new Account(
				Id = hh.Id,
				Name = hh.Name
			);

			// add up clients by ages
			setClientCountsByAge( newHH, allMembers );

			// if anything has changed, update this household
			if ( hh.Name != newHH.Name || hh.Adults__c != newHH.Adults__c || hh.Seniors__c != newHH.Seniors__c || hh.Children__c != newHH.Children__c || hh.Infants__c != newHH.Infants__c )
				hhToUpdate.add( newHH );
		}

		if (!hhToUpdate.isEmpty())
			update hhToUpdate;
	}

	// checks to see if anyone needs an updated age based on how long since the age was updated
	public void updateContactAgeIfOlder( list<Contact> clients ) {
		list<Contact> updatedMembers = new list<Contact>();
		for ( Contact c : clients ) {
			if ( c.Birthdate == null && c.Age__c != null && c.Age_Entry_Date__c != null ) {
				Boolean dateMoved = false;
				while ( c.Age_Entry_Date__c <= system.today().addYears(-1) ) {
					c.Age__c += 1;
					c.Age_Entry_Date__c = c.Age_Entry_Date__c.addYears(1);
					dateMoved = true;
				}
				if (dateMoved) 
					updatedMembers.add( c );
			}
		}
		if (!updatedMembers.isEmpty())
			update updatedMembers; 
	}

	private void setClientCountsByAge( Account hh, list<Contact> clist ) {
		// don't set hh client counts if all client ages are null
		Boolean weHaveAges = false;
		for ( Contact c : clist ) {
			if (c.Age__c != null) {
				weHaveAges = true;
				break;
			}
		}
		if (!weHaveAges) return;

		hh.Adults__c = 0;
		hh.Seniors__c = 0;
		hh.Children__c = 0;
		hh.Infants__c = 0;

		// add up the clients by age
		for ( Contact c : clist ) {	

			if (c.Inactive__c) {
				continue;
			}			
			else if ( c.Age__c == null ) hh.Adults__c += 1;
			else if ( c.Age__c > 60 ) hh.Seniors__c += 1;
			else if ( c.Age__c < 2 ) hh.Infants__c += 1;
			else if ( c.Age__c < 13 ) hh.Children__c += 1;
			else hh.Adults__c += 1;
		}		
	}

	public void setFirstVisitCheckbox( list<Food_Bank_Visit__c> visitList, map<Id, Food_Bank_Visit__c> oldMap, Boolean isInsert) {

		// TODO: if no visit date, assume the create date (or today for new records)

		// short circuit if this update is from this trigger itself
		if (nowUpdatingVisitCheckbox) return;

		list<Food_Bank_Visit__c> visitsToUpdate = new list<Food_Bank_Visit__c>();

		// organize visits in the trigger list by household and year
		map<String, List<Food_Bank_Visit__c>> cvMap = new map<String, List<Food_Bank_Visit__c>>();
		set<Integer> yearSet = new set<Integer>();
		set<Id> hhSet = new set<Id>();

		// in case of delete, need to set up to recalculate from existing records
		if (visitList == null) {
			visitList = new list<Food_Bank_Visit__c>();
			for (Food_Bank_Visit__c cv : oldMap.values()) {
				if (cv.Visit_Date__c != null) {
					hhSet.add(cv.Household__c);
					yearSet.add(cv.Visit_Date__c.year());
				}				
			}			
		}

		// collect visit years
		for (Food_Bank_Visit__c cv : visitList) {
			hhSet.add(cv.Household__c);
			Integer visitYear = (cv.Visit_Date__c == null) ? system.today().year() : cv.Visit_Date__c.year();
			yearSet.add(visitYear);
		}

		// query for all existing visits for those HHs this year and add them to the map
		set<Id> visitIdsOutsideTriggerSet = new set<Id>();
		for (Food_Bank_Visit__c cv : [select id, Household__c, Visit_Date__c, First_Visit_This_Year__c from Food_Bank_Visit__c 
												where Household__c in : hhSet and CALENDAR_YEAR(Visit_Date__c) in : yearSet 
												and Id not in : visitList order by Id]) {

			Integer visitYear = (cv.Visit_Date__c == null) ? system.today().year() : cv.Visit_Date__c.year();
			visitIdsOutsideTriggerSet.add(cv.Id);
			String mapKey = String.valueOf(visitYear) + cv.Household__c;
			if (cvMap.containsKey(mapKey))
				cvMap.get(mapKey).add(cv);
			else
				cvMap.put(mapKey, new list<Food_Bank_Visit__c>{ cv });
		}

		Date date12MonthsAgo = system.today().addYears(-1);
		List<Food_Bank_Service_Day__c> foodBankServiceDays = [SELECT Service_Day__c FROM Food_Bank_Service_Day__c WHERE Service_Day__c > :date12MonthsAgo];
		Set<Date> serviceDays = new Set<Date>();
		for (Food_Bank_Service_Day__c serviceDay :foodBankServiceDays) {
			serviceDays.add(serviceDay.Service_Day__c);
		}
		List<Food_Bank_Service_Day__c> insertServiceDays = new List<Food_Bank_Service_Day__c>();

		// add visits being updated
		for (Food_Bank_Visit__c cv : visitList) {

			// Check to add Service Day
			Date visitDay = date.newinstance(cv.Visit_Date__c.year(), cv.Visit_Date__c.month(), cv.Visit_Date__c.day());
			if (!serviceDays.contains(visitDay)) {

				serviceDays.add(visitDay);
				insertServiceDays.add( new Food_Bank_Service_Day__c(
					Name = String.valueOf(visitDay),
					Service_Day__c = visitDay
				));
			}

			Integer visitYear = (cv.Visit_Date__c == null) ? system.today().year() : cv.Visit_Date__c.year();
			String mapKey = String.valueOf(visitYear) + cv.Household__c;
			if (cvMap.containsKey(mapKey))
				cvMap.get(mapKey).add(cv);
			else
				cvMap.put(mapKey, new list<Food_Bank_Visit__c>{ cv });

			if (oldMap != null) {
				Food_Bank_Visit__c oldCv = oldMap.get(cv.Id);
				hhSet.add(oldCv.Household__c);
				if (oldCv.Visit_Date__c != null)
					yearSet.add(oldCv.Visit_Date__c.year());
			}
		}

		if (!insertServiceDays.isEmpty()) {
			insert insertServiceDays;
		}

		// for each client/year combo, find the first visit of the year and mark it as such
		for (String mapKey : cvMap.keyset()) {
			list<Food_Bank_Visit__c> cvListThisYear = cvMap.get(mapKey);
			Food_Bank_Visit__c firstVisit;
			for (Food_Bank_Visit__c cv : cvListThisYear) {
				if (firstVisit == null || firstVisit.Visit_Date__c == null || cv.Visit_Date__c < firstVisit.Visit_Date__c)
					firstVisit = cv;
			}
			for (Food_Bank_Visit__c cv : cvListThisYear) {
				// if the checkbox has the wrong value for this record, update it
				if ((cv == firstVisit && !cv.First_Visit_This_Year__c) || (cv != firstVisit && cv.First_Visit_This_Year__c)) {
					cv.First_Visit_This_Year__c = (cv == firstVisit);
					// only records not in the trigger set actually need to be updated
					if (visitIdsOutsideTriggerSet.contains(cv.Id))
						visitsToUpdate.add(cv);
				}
			}
		}

		// update any existing visits that need updating
		nowUpdatingVisitCheckbox = true;
		if (!visitsToUpdate.isEmpty())
			update visitsToUpdate;
		nowUpdatingVisitCheckbox = false;

		// Create visits for each person in the household
		system.debug('***** FoodBankTrigger::setFirstVisitCheckbox isInsert: ' + isInsert + ' Create_Visit_Every_Household_Member__c: ' + FoodBankSettings.general.Create_Visit_Every_Household_Member__c);
		if (isInsert && FoodBankSettings.general.Create_Visit_Every_Household_Member__c) {

			Map<Id, List<Id>> contacts = new Map<Id, List<Id>>();
			for (Contact contact : [
				SELECT Id, AccountId
				FROM Contact
				WHERE AccountId in :hhSet AND Inactive__c = false]) {
				
				if (contacts.containsKey(contact.AccountId)) {
					List<Id> accountContacts = contacts.remove(contact.AccountId);
					accountContacts.add(contact.Id);
					contacts.put(contact.AccountId, accountContacts);
				}
				else {
				   contacts.put(contact.AccountId, new List<Id> { contact.Id });
				}
			}

			List<Food_Bank_Visit__c> additionalVisits = new List<Food_Bank_Visit__c>();
			for (Food_Bank_Visit__c cv : visitList) {

				if (cv.Visitor_Related__c) {
					continue;
				}

				if (cv.Visit_Type__c <> null && cv.Visit_Type__c == 'Baby Pantry') {
					// To Do: Fix this in the future so not looking at static Baby Pantry name, have a list of something for types not to create visits on all HH members
					continue;
				}

				if (contacts.containsKey(cv.Household__c)) {

					List<Id> accountContacts = contacts.get(cv.Household__c);

					for (Id contactId :accountContacts) {
						if (contactId != cv.Visitor__c) {
							additionalVisits.add( new Food_Bank_Visit__c(
								Visit_Date__c = cv.Visit_Date__c,
								Household__c = cv.Household__c,
								Visit_Type__c = cv.Visit_Type__c,
								Visitor__c = contactId,
								Visitor_Related__c = true
							));
						}
					}
				}
			}

			if (!additionalVisits.isEmpty()) {
				insert additionalVisits;	
			}

			// Check to delete Vistor Related records
			// NOTE: Salesforce 2019 release might be increasing storage from 1GB to 10GB which would mean don't need to worry about deleting old visits
/*
			DateTime visitDateThreshold = system.now().addMonths(-14);
			List<Food_Bank_Visit__c> deleteVisits = [
				SELECT Id
				FROM Food_Bank_Visit__c
				WHERE Visit_Date < :visitDateThreshold];

			if (!deleteVisits.isEmpty()) {
				delete deleteVisits;
			}
*/
		}
	}
}