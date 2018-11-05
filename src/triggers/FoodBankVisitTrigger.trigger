trigger FoodBankVisitTrigger on Food_Bank_Visit__c (before insert, before update, after delete) {

	FoodBankTrigger.get().setFirstVisitCheckbox( Trigger.New, Trigger.oldMap );

}