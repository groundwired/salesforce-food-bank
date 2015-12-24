public with sharing class FoodBankTrigger {

	// only need one instance of this class per transaction
	private static FoodBankTrigger instance;
	public static FoodBankTrigger get() {
		if (instance == null) instance = new FoodBankTrigger();
		return instance;
	}

	private static Boolean nowUpdatingVisitCheckbox = false;

/*
select Id, Name, Monthly_Visit_Limit__c, Monthly_Base_Points__c, Monthly_Points_Per_Adult__c, Monthly_Points_Per_Child__c, 
Track_Points__c, Require_Unique_Address__c, Welcome_Message__c, Welcome_Alert__c, Proof_of_Address_Required__c, 
Proof_of_Address_Update_Interval__c, Allow_Overage__c, Weekly_Visit_Limit__c, Allow_Box_Size_Override__c from Food_Bank_Settings__c

select Id, Name, Monthly_Limit__c, Allow_Overage__c, Sort_Order__c from Food_Bank_Commodity__c

select Id, Name, Client_Household__c, First_Name__c, Last_Name__c, Birthdate__c, Age__c, Age_Entry_Date__c from Client__c

select Id, Name, Household__c, Visit_Date__c, Adults__c, Children__c, Infants__c, Seniors__c, Homeless__c, 
First_Visit_This_Year__c, Points_Used__c, Box_Type__c, Notes__c, Commodity_Usage_JSON__c, Total_People__c, 
More_Than_One_Person__c, Homeless_Counter__c from Client_Visit__c

select Id, Name, First_Visit__c, Most_Recent_Visit__c, Total_Visits__c, Proof_of_Address_Date__c, 
Homeless__c, Address__c, City__c, State__c, Postal_Code__c, Inactive__c, Notes__c, Special_Diet__c, 
Source__c, External_ID__c, No_Cook__c, Adults__c, Children__c, Infants__c, Seniors__c, 
Current_Points_Used__c, Monthly_Points_Available__c, Current_Points_Remaining__c, Client_Names__c, 
Commodity_Usage_JSON__c, Full_Address__c from Client_Household__c
*/

	public void updateClientName( list<Client__c> clientList, map<id, Client__c> oldMap ) {

		for (Client__c cl : clientList) {

			// if we have first and last, set Name
			Client__c old = (oldMap == null) ? new Client__c() : oldMap.get(cl.Id);
			if ( cl.Last_Name__c != null && ( cl.Last_Name__c != old.Last_Name__c || cl.First_Name__c != old.First_Name__c) ) {
				cl.Name = ((cl.First_Name__c == null) ? '' : cl.First_Name__c + ' ') + cl.Last_Name__c;

			// otherwise, if we have name, set first and last
			} else if ( cl.Last_Name__c == null && cl.Name != null ) {
				list<String> names = cl.Name.split(' ');
				cl.Last_Name__c = names.remove(names.size() - 1);
				cl.First_Name__c = ( names.isEmpty() ) ? null : String.join(names, ' ');
			}
		}
	}

	public void updateClientAge( list<Client__c> clientList, map<id, Client__c> oldMap ) {

		for ( Client__c c : clientList ) {

			// if we have a birthdate, use it to set the age
			if ( c.Birthdate__c != null ) {
				c.Age__c = getAge( c.Birthdate__c );
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

		return yrs;
	}

	// after trigger to maintain household record based on client changes
	public void fixHouseholdForClientChange( list<Client__c> clientList, map<id, Client__c> oldMap, Boolean isDelete ) {

		map<id, list<Client__c>> triggerHHMap = new map<id, list<Client__c>>();
		
		if ( clientList != null ) {
			// collect all the households and clients in the trigger set
			for ( Client__c c : clientList ) {
				if (!triggerHHMap.containsKey(c.Client_Household__c)) {
					triggerHHMap.put(c.Client_Household__c, new list<Client__c>{ c });
				} else {
					triggerHHMap.get(c.Client_Household__c).add(c);
				}
			}
		}

		// fix the household client names field as needed
		list<Client_Household__c> hhToUpdate = new list<Client_Household__c>();

		for ( Client_Household__c hh : 
				[select Id, Full_Address__c, Client_Names__c, Adults__c, Seniors__c, Children__c, Infants__c,
					(select Id, Name, First_Name__c, Last_Name__c, Age__c, Age_Entry_Date__c, Birthdate__c, 
						Client_Household__c from Clients__r
						where Id not in : clientList order by createdDate, Id, Age__c desc)
					from Client_Household__c where id in : triggerHHMap.keyset()] ) {

			list<Client__c> allMembers = new list<Client__c>();
			for ( Client__c c : hh.Clients__r )
				allMembers.add( c );

			// may need to fix ages of clients we query for (if they have an expired age and no birthdate)
			updateClientAgeIfOlder( allMembers ); 

			//TODO: should sort these into the list by create date to avoid reshuffling
			if (!isDelete) {
				for (Client__c c : triggerHHMap.get( hh.Id ) )
					allMembers.add( c );
			}

			Client_Household__c newHH = new Client_Household__c(
				Id = hh.Id,
				Client_Names__c = FoodBankHouseholds.calculateHHName( hh, allMembers )
			);

			// add up clients by ages
			setClientCountsByAge( newHH, allMembers );

			// if anything has changed, update this household
			if ( hh.Client_Names__c != newHH.Client_Names__c || hh.Adults__c != newHH.Adults__c || hh.Seniors__c != newHH.Seniors__c || hh.Children__c != newHH.Children__c || hh.Infants__c != newHH.Infants__c )
				hhToUpdate.add( newHH );
		}

		if (!hhToUpdate.isEmpty())
			update hhToUpdate;
	}

	// checks to see if anyone needs an updated age based on how long since the age was updated
	public void updateClientAgeIfOlder( list<Client__c> clients ) {
		list<Client__c> updatedMembers = new list<Client__c>();
		for ( Client__c c : clients ) {
			if ( c.Birthdate__c == null && c.Age__c != null && c.Age_Entry_Date__c != null ) {
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

	private void setClientCountsByAge( Client_Household__c hh, list<Client__c> clist ) {
		// don't set hh client counts if all client ages are null
		Boolean weHaveAges = false;
		for ( Client__c c : clist ) {
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
		for ( Client__c c : clist ) {				
			if ( c.Age__c == null )	  hh.Adults__c += 1;
			else if ( c.Age__c > 60 ) hh.Seniors__c += 1;
			else if ( c.Age__c < 2 )  hh.Infants__c += 1;
			else if ( c.Age__c < 13 ) hh.Children__c += 1;
			else                      hh.Adults__c += 1;
		}		
	}

	public void setFirstVisitCheckbox( list<Client_Visit__c> visitList, map<Id, Client_Visit__c> oldMap ) {

		// short circuit if this update is from this trigger itself
		if (nowUpdatingVisitCheckbox) return;

		list<Client_Visit__c> visitsToUpdate = new list<Client_Visit__c>();

		// organize visits in the trigger list by household and year
		map<String, List<Client_Visit__c>> cvMap = new map<String, List<Client_Visit__c>>();
		set<Integer> yearSet = new set<Integer>();
		set<Id> hhSet = new set<Id>();

		// in case of delete, need to set up to recalculate from existing records
		if (visitList == null) {
			visitList = new list<Client_Visit__c>();
			for (Client_Visit__c cv : oldMap.values()) {
				if (cv.Visit_Date__c != null) {
					hhSet.add(cv.Household__c);
					yearSet.add(cv.Visit_Date__c.year());
				}				
			}			
		}

		for (Client_Visit__c cv : visitList) {
			if (cv.Visit_Date__c != null) {
				hhSet.add(cv.Household__c);
				yearSet.add(cv.Visit_Date__c.year());
				String mapKey = String.valueOf(cv.Visit_Date__c.year()) + cv.Household__c;
				if (cvMap.containsKey(mapKey))
					cvMap.get(mapKey).add(cv);
				else
					cvMap.put(mapKey, new list<Client_Visit__c>{ cv });

			} else {
				cv.First_Visit_This_Year__c = false;
			}
			if (oldMap != null) {
				Client_Visit__c oldCv = oldMap.get(cv.Id);
				hhSet.add(oldCv.Household__c);
				if (oldCv.Visit_Date__c != null)
					yearSet.add(oldCv.Visit_Date__c.year());
			}
		}

		// query for all existing visits for those HHs this year and add them to the map
		set<Id> visitIdsOutsideTriggerSet = new set<Id>();
		for (Client_Visit__c cv : [select id, Household__c, Visit_Date__c, First_Visit_This_Year__c from Client_Visit__c 
												where Household__c in : hhSet and CALENDAR_YEAR(Visit_Date__c) in : yearSet 
												and Id not in : visitList]) {

			visitIdsOutsideTriggerSet.add(cv.Id);
			String mapKey = String.valueOf(cv.Visit_Date__c.year()) + cv.Household__c;
			if (cvMap.containsKey(mapKey))
				cvMap.get(mapKey).add(cv);
			else
				cvMap.put(mapKey, new list<Client_Visit__c>{ cv });
		}

		// for each client/year combo, find the first visit of the year and mark it as such
		for (String mapKey : cvMap.keyset()) {
			list<Client_Visit__c> cvListThisYear = cvMap.get(mapKey);
			Client_Visit__c firstVisit;
			for (Client_Visit__c cv : cvListThisYear) {
				if (firstVisit == null || firstVisit.Visit_Date__c == null || cv.Visit_Date__c < firstVisit.Visit_Date__c)
					firstVisit = cv;
			}
			for (Client_Visit__c cv : cvListThisYear) {
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
	}
}