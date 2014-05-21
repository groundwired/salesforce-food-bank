public with sharing class FoodBankManager {

    public class FoodBankException extends Exception {} 

    private map<String, String> params = ApexPages.CurrentPage().getParameters();

    public Class ClientCheckin {
        public String clientId { get; private set; }
        public String clientName { get; private set; }
        public Decimal pointsRemaining { get; private set; }
        public String boxSize { get; private set; }
        public DateTime checkInTime { get; private set; }
        public Boolean checkinNotToday { get; private set; }
    }

    @RemoteAction
    public static list<ClientCheckin> getCheckedInList() {
        list<ClientCheckin> chkList = new list<ClientCheckin>();
        for (Food_Bank_Checkin__c fbc : Food_Bank_Checkin__c.getAll().values()) {
            ClientCheckin cc = new ClientCheckin();
            cc.clientId = fbc.name;
            cc.clientName = fbc.Client_Name__c;
            cc.pointsRemaining = fbc.Points_Remaining__c;
            cc.boxSize = fbc.Box_Size__c;
            cc.checkInTime = fbc.Check_In_Time__c;
            cc.checkinNotToday = (cc.checkInTime != null && cc.checkInTime.date() != system.today());
            chkList.add( cc );
        }
        return chkList;
    }

    @RemoteAction
    public static Client_Household__c getHouseholdDetail( Id hhid ) {
        Client_Household__c hh = 
            [select Id, Name, CreatedDate, LastModifiedDate, First_Visit__c, Most_Recent_Visit__c, 
                Total_Visits__c, Proof_of_Address_Date__c, Homeless__c, Address__c, City__c, State__c, Postal_Code__c, 
                Inactive__c, Notes__c, Special_Diet__c, Source__c, External_ID__c, No_Cook__c, Adults__c, 
                Children__c, Infants__c, Seniors__c, Client_Names__c, Full_Address__c, 
                Staff_Notes__c, Infant_Card_Expires__c, Phone__c,
                (select Id, Name, First_Name__c, Last_Name__c, Age_Group__c, Age__c, Birthdate__c from Clients__r),
                (select Points_Used__c, Commodity_Usage_JSON__c from Visits__r where Visit_Date__c = THIS_MONTH)
                from Client_Household__c where id = :hhid];

        if (FoodBankSettings.general.Track_Points__c)
            hh.Monthly_Points_Available__c = getMonthlyPoints( hh );

        /*
        // if last visit date is not this month, recalculate points
        if (FoodBankSettings.general.Track_Points__c) {
            hh.Monthly_Points_Available__c = getMonthlyPoints( hh );
            if (hh.Most_Recent_Visit__c == null) {
                hh.Current_Points_Used__c = 0;
            } else if (hh.Current_Points_Used__c == null || hh.Most_Recent_Visit__c.year() != system.today().year() || hh.Most_Recent_Visit__c.month() != system.today().month()) {
                AggregateResult ar = [SELECT SUM(Points_Used__c) TotalPoints FROM Client_Visit__c WHERE Id = : hh.id AND Visit_Date__c = THIS_MONTH];
                Decimal pu = (Decimal)(ar.get('TotalPoints'));
                hh.Current_Points_Used__c = (pu == null) ? 0 : pu;
            }
        }
        */
        return hh;
    }

    @RemoteAction
    public static list<Client_Visit__c> getVisitHistory( Id hhid ) {
        return 
            [select Id, Visit_Date__c, Points_Used__c, Notes__c
                from Client_Visit__c
                where Household__c = :hhid
                order by Visit_Date__c DESC limit 20];
    }

    @RemoteAction
    public static Client_Household__c saveHousehold( Client_Household__c hh ) {

        if (hh.Id == null)
            insert hh;
        else
            update hh;

        hh = getHouseholdDetail( hh.Id );
        return hh;
    }

    @RemoteAction
    public static Client_Household__c saveHouseholdAndMembers( Client_Household__c hh, list<Client__c> clients) {

        hh.Monthly_Points_Available__c = getMonthlyPoints( hh );  // is this by trigger?  how about the name?
        if (hh.Id == null)
            insert hh;
        else
            update hh;

        return saveHouseholdMembers( hh.id, clients );
    }

    @RemoteAction
    public static Client_Household__c saveHouseholdMembers( Id hhid, list<Client__c> clients ) {
        
        if (clients != null) {
            list<Client__c> clientsToInsert = new list<Client__c>();
            list<Client__c> clientsToUpdate = new list<Client__c>();
            set<Id> clientIds = new set<Id>();
            
            for (Client__c client : clients) {
                if (client.Last_Name__c != null) {
                    client.Client_Household__c = hhid;              
                    if (client.Id == null) {
                        clientsToInsert.add(client.clone());
                    } else {
                        clientsToUpdate.add(client);
                        clientIds.add(client.Id);
                    }
                }
            }
            list<Client__c> clientsToDelete = [select id from Client__c where Client_Household__c = : hhid
                and Id not in :clientIds];

            if (!clientsToDelete.isEmpty())
                delete clientsToDelete;
            if (!clientsToUpdate.isEmpty()) 
                update clientsToUpdate;
            if (!clientsToInsert.isEmpty()) 
                insert clientsToInsert;
        }

        // TODO: recalculation needed?
        return getHouseholdDetail( hhid );
    }

    static Decimal getMonthlyPoints( Client_Household__c hh ) {
        Decimal pts = 0;
        if (hh != null) {
            if (FoodBankSettings.general.Monthly_Base_Points__c != null)
                pts += FoodBankSettings.general.Monthly_Base_Points__c;
            if (FoodBankSettings.general.Monthly_points_per_Adult__c != null && hh.Adults__c != null)
                pts += (FoodBankSettings.general.Monthly_points_per_Adult__c * hh.Adults__c);
            if (FoodBankSettings.general.Monthly_points_per_Adult__c != null && hh.Seniors__c != null)
                pts += (FoodBankSettings.general.Monthly_points_per_Adult__c * hh.Seniors__c);
            if (FoodBankSettings.general.Monthly_points_per_Child__c != null && hh.Children__c != null)
                pts += (FoodBankSettings.general.Monthly_points_per_Child__c * hh.Children__c);
            if (FoodBankSettings.general.Monthly_points_per_Child__c != null && hh.Infants__c != null)
                pts += (FoodBankSettings.general.Monthly_points_per_Child__c * hh.Infants__c);
        }
        return pts;
    }

    @RemoteAction
    public static Client_Household__c createNewHousehold( Client_Household__c hhData, list<Client__c> clientData ) {
        Client_Household__c hh;

        // calculate points and commodity data and save

        return hh;
    }

    @RemoteAction
    public static void checkIn( Id hhid ) {
        if ( Food_Bank_Checkin__c.getInstance( hhid ) != null )
            return;

        Food_Bank_Checkin__c fbc = new Food_Bank_Checkin__c();

        Client_Household__c hh = 
            [select id, client_names__c, Adults__c, Seniors__c, Children__c, Infants__c,
                (select Points_Used__c from Visits__r where Visit_Date__c = THIS_MONTH)
                from Client_Household__c where id = :hhid];

        if (Food_Bank_Checkin__c.getInstance( hhid ) != null) {
            throw new FoodBankException('Already checked in.');
        } else {
            fbc.name = hh.id;
            fbc.Client_Name__c = hh.client_names__c;
            fbc.Points_Remaining__c = getMonthlyPoints( hh );
            for (Client_Visit__c cv : hh.Visits__r)
                if (cv.Points_Used__c != null) fbc.Points_Remaining__c -= cv.Points_Used__c;
            fbc.Check_In_Time__c = system.now();
            insert fbc;
        }
    }

    @RemoteAction
    public static void cancelCheckIn( Id hhid ) {
        Food_Bank_Checkin__c fbc = Food_Bank_Checkin__c.getInstance( hhid );
        if (fbc != null) delete fbc;
    }

    @RemoteAction
    public static FoodBankStats getStats( String timeframe ) {

        FoodBankStats s = new FoodBankStats();
        s.queryStats(timeframe);
        return s;
    }

// TODO: REFACTOR FOR CONSISTENCY????
    public Class ClientHousehold {
        public String id;
        public String value;
        public String name;
        public String addr;
        //public list<String> tags; 
    }

    @RemoteAction
    public static list<ClientHousehold> queryHouseholds( String query){//, Boolean includeInactive ) {
        list<ClientHousehold> hhRet = new list<ClientHousehold>();
        List<List<SObject>> resultList = 
            //(includeInactive) ?
            //  [FIND :(query + '*') RETURNING Client_Household__c( Id, Client_Names__c, Address__c, Full_Address__c
   //               WHERE Client_Names__c != null ORDER BY Client_Names__c )] :
                [FIND :(query + '*') RETURNING Client_Household__c( Id, Client_Names__c, Address__c, Full_Address__c
                    WHERE Client_Names__c != null AND Inactive__c != true ORDER BY Client_Names__c )];

// TODO: should not need to translate here
        for (sObject obj : resultList[0]) {
            Client_Household__c rec = (Client_Household__c)obj;
            ClientHousehold chh = new ClientHousehold();
            chh.id = rec.Id;
            chh.name = rec.Client_Names__c;
            chh.value = rec.Client_Names__c + ((rec.Address__c != null) ? (' (' + rec.Address__c + ')') : '');
            chh.addr = rec.Full_Address__c;
            hhRet.add( chh );   
        }
        return hhRet;
    }

    // custom class allows us to return all settings in a single remote call
    public class AppSettings {
        public Food_Bank_Settings__c general { get; set; }
        public List<Food_Bank_Commodity__c> commodities { get; set; }
        public List<Food_Bank_Box_Settings__c> boxes { get; set; }
    }

    @RemoteAction
    public static AppSettings getAppSettings() {
        AppSettings s = new AppSettings(); 
        s.general = FoodBankSettings.general;
        s.commodities = FoodBankSettings.commodities;
        s.boxes = FoodBankSettings.boxes;
        return s;
    }

    @RemoteAction
    public static Id logVisit( Id hhId, String boxType, Integer pointsUsed, Map<String, Integer> commodityUsage, String visitNotes ) {

        // get the HH detail
        Client_Household__c[] hhs = 
            [select Id, Name, Adults__c, Children__c, Infants__c, Seniors__c, Homeless__c, Inactive__c
                from Client_Household__c where id = :hhid];

        if ( hhs.isEmpty() ) {
            throw new FoodBankException('Household not found.');
            return null;
        }

        Client_Household__c hh = hhs[0];
    
        // TODO: validate remaining points? non-negative and under limit (unless setting allows exception)

        // TODO: activate inactive client? or disallow visit?

        // log the visit
        Client_Visit__c cv = new Client_Visit__c(
            Household__c = hh.Id,
            Adults__c = hh.Adults__c,
            Seniors__c = hh.Seniors__c,
            Children__c = hh.Children__c,
            Infants__c = hh.Infants__c,
            Homeless__c = hh.Homeless__c,
            Points_Used__c = pointsUsed,
            Box_Type__c = boxType,
            Notes__c = visitNotes
        );
        if (commodityUsage != null && !commodityUsage.isEmpty())
            cv.Commodity_Usage_JSON__c = JSON.serializePretty(commodityUsage);
        insert cv;

        // TODO: recalc and save the remaining points on household
        if (pointsUsed != null && pointsUsed > 0) {}

        // remove the client from checkin list
        Food_Bank_Checkin__c fbc = Food_Bank_Checkin__c.getInstance( hhid );
        if (fbc != null) delete fbc;

        return cv.id;
    }
}