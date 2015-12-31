trigger ClientHouseholdTrigger on Client_Household__c (before update, before insert) {

	if (Trigger.isBefore) {
		FoodBankTrigger.get().updateProofDates( Trigger.New, Trigger.oldMap );
	}

}