public with sharing class FoodBankStats {

	public list<Integer> hhVisits { get; private set; }
	public list<Integer> onePerson { get; private set; }
	public list<Integer> overOnePerson { get; private set; }
	public list<Integer> adults { get; private set; }
	public list<Integer> children { get; private set; }
	public list<Integer> infants { get; private set; }
	public list<Integer> seniors { get; private set; }
	public list<Integer> total { get; private set; }
	public list<Integer> homeless { get; private set; }
	public list<Integer> outofarea { get; private set; }
	public Boolean trackPoints { get; private set; }
	public Integer pointsUsed { get; private set; }
	public map<String, Integer> boxTotals { get; private set; }
	public String timeframe { get; private set; }

	public FoodBankStats() {
		hhVisits = new list<Integer>{ 0, 0, 0 };
		onePerson = new list<Integer>{ 0, 0, 0 };
		overOnePerson = new list<Integer>{ 0, 0, 0 };
		adults = new list<Integer>{ 0, 0, 0 };
		children = new list<Integer>{ 0, 0, 0 };
		infants = new list<Integer>{ 0, 0, 0 };
		seniors = new list<Integer>{ 0, 0, 0 };
		total = new list<Integer>{ 0, 0, 0 };
		homeless = new list<Integer>{ 0, 0, 0 };
		outofarea = new list<Integer>{ 0, 0, 0 };
		pointsUsed = 0;
		boxTotals = new map<String, Integer>();
	}

	public PageReference loadStats() {
		map<String, String> params = ApexPages.CurrentPage().getParameters();
		timeframe = params.get('tfcode');
		if (timeframe != null) {
			
			queryStats( timeframe );

			// TODO: if we are using boxes, run a separate aggregate query for total usage
			// if (FoodBankSettings.boxes != null && !FoodBankSettings.boxes.isEmpty()) {
			// 	queryBoxTotals( tfcode );
			// }
		}
		trackPoints = FoodBankSettings.general.Track_Points__c;
		
		return null;
	}

	public void queryStats( String timeframe ) {

		// Households Served Stats
		// 	Not able to use Aggregrate because there is not DISTINCT Count in SOQL for Household__c
		String queryHouseholds = 'SELECT First_Visit_This_Year__c, ' +
					'More_Than_One_Person__c, ' +
					'Household__c ' +
					'FROM Food_Bank_Visit__c WHERE Visit_Date__c = ' + timeframe;

		Set<Id> householdOnePersonTotalVisits = new Set<Id>();
		Set<Id> householdOnePersonFirstVisits = new Set<Id>();
		Set<Id> householdMoreThanOnePersonTotalVisits = new Set<Id>();
		Set<Id> householdMoreThanOnePersonFirstVisits = new Set<Id>();
		for (Food_Bank_Visit__c visit : Database.query(queryHouseholds)) {
			if (visit.First_Visit_This_Year__c) {
				if (visit.More_Than_One_Person__c == 0.0) {
					householdOnePersonFirstVisits.add(visit.Household__c);
				 } else {
					householdMoreThanOnePersonFirstVisits.add(visit.Household__c);
				 }
			} else {
				if (visit.More_Than_One_Person__c == 0.0) {
					householdOnePersonTotalVisits.add(visit.Household__c);
				 } else {
					householdMoreThanOnePersonTotalVisits.add(visit.Household__c);
				 }
			}

		}		

		// Household - First Visit Stats
		onePerson[0] = householdOnePersonFirstVisits.size();
		overOnePerson[0] = householdMoreThanOnePersonFirstVisits.size();
		hhVisits[0] = onePerson[0] + overOnePerson[0];

		// Household - Duplicated Stats
		onePerson[1] = householdOnePersonTotalVisits.size();
		overOnePerson[1] = householdMoreThanOnePersonTotalVisits.size();
		hhVisits[1] = onePerson[1] + overOnePerson[1];

		// Household - Total Stats
		onePerson[2] = onePerson[0] + onePerson[1];
		overOnePerson[2] = overOnePerson[0] + overOnePerson[1];
		hhVisits[2] = onePerson[2] + overOnePerson[2];

		// Invididuals Served Stats
		String queryIndividuals = 'SELECT First_Visit_This_Year__c Unduplicated, ' +
					'SUM(Adults__c) Adults, SUM(Children__c) Children, SUM(Infants__c) Infants, ' +
					'SUM(Seniors__c) Seniors, ' +
					'SUM(Homeless_Counter__c) Homeless, SUM(Out_Of_Area_Counter__c) OutOfArea, SUM(Points_Used__c) TotalPoints ' +
					'FROM Food_Bank_Visit__c WHERE Visit_Date__c = ' + timeframe +
			 		' GROUP BY ROLLUP(First_Visit_This_Year__c)';

		for (AggregateResult r : Database.query(queryIndividuals)) {
			Boolean undup = (Boolean)(r.get('Unduplicated'));
			Integer i = (undup == true) ? 0 : (undup == false) ? 1 : 2;
			adults[i] = grabFromResult(r, 'Adults');
			children[i] = grabFromResult(r, 'Children');
			infants[i] = grabFromResult(r, 'Infants');
			seniors[i] = grabFromResult(r, 'Seniors');
			total[i] = adults[i] + children[i] + infants[i] + seniors[i];
			homeless[i] = grabFromResult(r, 'Homeless');
			outofarea[i] = grabFromResult(r, 'OutOfArea');
			if (i == 2) pointsUsed = grabFromResult(r, 'TotalPoints');
		}		
	}

	private Integer grabFromResult(AggregateResult res, String fld) {
		Decimal thisResult = (Decimal)(res.get(fld));
		return (thisResult != null) ? thisResult.intValue() : 0;
	}
}