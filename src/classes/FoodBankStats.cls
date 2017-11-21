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
	public Boolean trackPoints { get; private set; }
	public Integer pointsUsed { get; private set; }
	public map<String, Integer> boxTotals { get; private set; }
	public String timeframe {get; private set; }

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
		pointsUsed = 0;
		boxTotals = new map<String, Integer>();
	}

	public PageReference loadStats() {
		map<String, String> params = ApexPages.CurrentPage().getParameters();
		String tfcode = params.get('tfcode');
		if (tfcode != null) {
			
			queryStats( tfcode );

			// TODO: if we are using boxes, run a separate aggregate query for total usage
			// if (FoodBankSettings.boxes != null && !FoodBankSettings.boxes.isEmpty()) {
			// 	queryBoxTotals( tfcode );
			// }
		}
		trackPoints = FoodBankSettings.general.Track_Points__c;
		return null;
	}

	public void queryStats( String timeframe ) {
		String q = 'SELECT First_Visit_This_Year__c Unduplicated, ' +
					'COUNT(Id) HHVisits, SUM(Adults__c) Adults, SUM(Children__c) Children, SUM(Infants__c) Infants, ' +
					'SUM(Seniors__c) Seniors, SUM(Total_People__c) TotalPeople, SUM(More_Than_One_Person__c) MoreThanOnePerson, ' +
					'SUM(Homeless_Counter__c) Homeless, SUM(Points_Used__c) TotalPoints ' +
					'FROM Client_Visit__c WHERE Visit_Date__c = ' + timeframe +
			 		' GROUP BY ROLLUP(First_Visit_This_Year__c)';

		for (AggregateResult r : Database.query(q)) {
			Boolean undup = (Boolean)(r.get('Unduplicated'));
			Integer i = (undup == true) ? 0 : (undup == false) ? 1 : 2;
			hhVisits[i] = grabFromResult(r, 'HHVisits');
			overOnePerson[i] = grabFromResult(r, 'MoreThanOnePerson');
			onePerson[i] = hhVisits[i] - overOnePerson[i];
			adults[i] = grabFromResult(r, 'Adults');
			children[i] = grabFromResult(r, 'Children');
			infants[i] = grabFromResult(r, 'Infants');
			seniors[i] = grabFromResult(r, 'Seniors');
			total[i] = grabFromResult(r, 'TotalPeople');
			homeless[i] = grabFromResult(r, 'Homeless');
			if (i == 2) pointsUsed = grabFromResult(r, 'TotalPoints');
		}		
	}

	private Integer grabFromResult(AggregateResult res, String fld) {
		Decimal thisResult = (Decimal)(res.get(fld));
		return (thisResult != null) ? thisResult.intValue() : 0;
	}
}