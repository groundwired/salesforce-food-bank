trigger ClientTrigger on Contact (before insert, before update, after insert, after update, after delete) {

	if (Trigger.isBefore) {
		FoodBankTrigger.get().updateContactAge( Trigger.New, Trigger.oldMap );
	} else {
		if (Trigger.isDelete)
			FoodBankTrigger.get().fixHouseholdForContactChange( Trigger.Old, Trigger.oldMap, true );
		else
			FoodBankTrigger.get().fixHouseholdForContactChange( Trigger.New, Trigger.oldMap, false );
	}

}