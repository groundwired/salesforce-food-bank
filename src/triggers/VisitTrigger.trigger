trigger VisitTrigger on Client_Visit__c (before insert, before update, after delete) {

	FoodBankTrigger.get().setFirstVisitCheckbox( Trigger.New, Trigger.oldMap );

}