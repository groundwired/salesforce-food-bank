trigger ClientTrigger on Client__c (before insert, before update, after insert, after update, after delete) {

	if (Trigger.isBefore) {
		FoodBankTrigger.get().updateClientName( Trigger.New, Trigger.oldMap );
		FoodBankTrigger.get().updateClientAge( Trigger.New, Trigger.oldMap );
	} else {
		if (Trigger.isDelete)
			FoodBankTrigger.get().fixHouseholdForClientChange( Trigger.Old, Trigger.oldMap, true );
		else
			FoodBankTrigger.get().fixHouseholdForClientChange( Trigger.New, Trigger.oldMap, false );
	}

}