trigger ClientHouseholdTrigger on Account (before update, before insert) {

	if (Trigger.isBefore) {
		FoodBankTrigger.get().updateProofDates( Trigger.New, Trigger.oldMap );
	}

}