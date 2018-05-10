public with sharing class FoodBankManager {

    private static String Unknown = 'Unknown';

    public class FoodBankException extends Exception {}

    private map<String, String> params = ApexPages.CurrentPage().getParameters();

    public Class ClientCheckin {
        public Id clientId { get; private set; }
        public Id clientContactId { get; private set; }
        public String name { get; private set; }
        public Decimal pointsRemaining { get; private set; }
        public String boxSize { get; private set; }
        public DateTime checkInTime { get; private set; }
        public Boolean checkinNotToday { get; private set; }
    }

    @RemoteAction
    public static list<ClientCheckin> getCheckedInList() {
        list<ClientCheckin> chkList = new list<ClientCheckin>();

        //for (Food_Bank_Checkin__c fbc : Food_Bank_Checkin__c.getAll().values()) {
        //    delete fbc;
        //}

        for (Food_Bank_Checkin__c fbc : Food_Bank_Checkin__c.getAll().values()) {
            ClientCheckin cc = new ClientCheckin();
            cc.clientId = fbc.name;
            cc.clientContactId = fbc.Visitor__c;
            cc.name = String.format('{0} Household', new String[]{FoodBankManager.getContactName(fbc.Visitor__c)});
            cc.pointsRemaining = fbc.Points_Remaining__c;
            cc.boxSize = fbc.Box_Size__c;
            cc.checkInTime = fbc.Check_In_Time__c;
            cc.checkinNotToday = (cc.checkInTime != null && cc.checkInTime.date() != system.today());
            chkList.add( cc );
        }

        // Sort List
        for (Integer i =0; i < chkList.size(); i++) {
            for (Integer j = i; j > 0; j--) {
                if (chkList[j-1].checkInTime < chkList[j].checkInTime){
                    ClientCheckin temp = chkList[j];
                    chkList[j] = chkList[j-1];
                    chkList[j-1] = temp;
                }
            }
        }

        return chkList;
    }

    @RemoteAction
    public static Account getHouseholdDetail( Id hhid ) {
        Account hh =
            [select Id, Name, CreatedDate, LastModifiedDate, First_Visit__c, Most_Recent_Visit__c,
                Total_Visits__c, Homeless__c, Out_Of_Area__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Inactive__c, Notes__c, Source__c, External_ID__c, Adults__c,
                Children__c, Infants__c, Seniors__c, Tags__c,
                Staff_Notes__c, Phone, Proof_of_Address__c, Proof_of_Address_Date__c,
                (select Id, Name, FirstName, LastName, Age_Group__c, Age__c, Birthdate, Proof_of_Infant__c, Gender__c, Id_Number__c
                    from Contacts),
                (select Points_Used__c, Commodity_Usage_JSON__c from Visits__r where Visit_Date__c = THIS_MONTH)
                from Account where id = :hhid];

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
            [select Id, Visit_Date__c, Box_Type__c, Points_Used__c, Checkout_Weight__c, Notes__c, Visitor__r.Name
                from Client_Visit__c
                where Household__c = :hhid
                order by Visit_Date__c DESC limit 20];
    }

    @RemoteAction
    public static Account saveHousehold( Account hh ) {

        if (hh.Name == null)
            hh.Name = FoodBankManager.Unknown;

        if (hh.Id == null)
            insert hh;
        else
            update hh;

        hh = getHouseholdDetail( hh.Id );
        return hh;
    }

    @RemoteAction
    public static Account saveHouseholdAndMembers( Account hh, list<Contact> clients) {

        if (hh.Name == null || hh.Name == FoodBankManager.Unknown)
        {
            if (!clients.isEmpty())
                hh.Name = String.format('{0} Household', new String[]{clients[0].LastName});
            else
                hh.Name = FoodBankManager.Unknown;
        }

        hh.Monthly_Points_Available__c = getMonthlyPoints( hh );  // is this by trigger?  how about the name?
        if (hh.Id == null)
            insert hh;
        else
            update hh;

        return saveHouseholdMembers( hh.id, clients );
    }

    @RemoteAction
    public static Account saveHouseholdMembers( Id hhId, list<Contact> clients ) {

        if (clients != null) {
            list<Contact> clientsToInsert = new list<Contact>();
            list<Contact> clientsToUpdate = new list<Contact>();
            set<Id> clientIds = new set<Id>();

            for (Contact client : clients) {
                if (client.LastName != null) {

                    client.AccountId = hhId;

                    // ToDo - Integrate with NPSP Address Management 
                    Account hh = getHouseholdDetail( hhId );
                    client.MailingStreet = hh.BillingStreet;
                    client.MailingCity = hh.BillingCity;
                    client.MailingState = hh.BillingState;
                    client.MailingPostalCode = hh.BillingPostalCode;

                    if (client.Id == null) {
                        clientsToInsert.add(client.clone());
                    } else {
                        clientsToUpdate.add(client);
                        clientIds.add(client.Id);
                    }
                }
            }
            
            list<Contact> clientsToDelete = [select id from Contact where AccountId = : hhId
                and Id not in :clientIds];

            if (!clientsToDelete.isEmpty())
                delete clientsToDelete;
            if (!clientsToUpdate.isEmpty())
                update clientsToUpdate;
            if (!clientsToInsert.isEmpty())
                insert clientsToInsert;
        }

        return getHouseholdDetail( hhId );
    }

    static Decimal getMonthlyPoints( Account hh ) {
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

    static String getContactName(Id contactid){
        
        if (contactId == null) {
            return FoodBankManager.Unknown;
        }

		//Contact c = [select id, name from Contact where id =: contactid];
        list<Contact> c = [select Id, AccountId, Name from Contact where id =: contactid];
        if (!c.isEmpty()) {
            return c[0].Name;
        }

        return FoodBankManager.Unknown;
    }


    @RemoteAction
    public static Account createNewHousehold( Account hhData, list<Contact> clientData ) {
        Account hh;

        // calculate points and commodity data and save

        return hh;
    }

    @RemoteAction
    public static void checkIn( Id hhid, Id contactid) {

        Food_Bank_Checkin__c fbc = new Food_Bank_Checkin__c();

        Account hh =
            [select id, Name, Adults__c, Seniors__c, Children__c, Infants__c,
                (select Points_Used__c from Visits__r where Visit_Date__c = THIS_MONTH)
                from Account where id = :hhid];

        if (Food_Bank_Checkin__c.getInstance( hhid ) != null) {
            throw new FoodBankException('Already checked in.');
        } else {
            fbc.name = hhid;
            fbc.Points_Remaining__c = getMonthlyPoints( hh );
            for (Client_Visit__c cv : hh.Visits__r)
                if (cv.Points_Used__c != null) fbc.Points_Remaining__c -= cv.Points_Used__c;

            fbc.Check_In_Time__c = system.now();
            fbc.Visitor__c = contactid;

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

    @RemoteAction
    public static String getCustomLabel( String label ) {

        if (label == 'Box_Type__c')
            return System.Label.Food_Bank_Box_Type;

        return 'Undefined';
    }

// TODO: REFACTOR FOR CONSISTENCY????
    public Class ClientHousehold {
        public String id;
        public String contactid;
        public String value;
        public String name;
        public String addr;
        //public list<String> tags;
    }

    // queryHouseholds
    //  
    // query: User entered string in UI (e.g., name, address, partial address)  
    @RemoteAction
    public static list<ClientHousehold> queryHouseholds( String query){//, Boolean includeInactive ) {
        list<ClientHousehold> hhRet = new list<ClientHousehold>();

        // Id Number search: back part of the Id can frequently change so stripe off back half of query to try for match
        String halfquery = query;
        if (halfquery.length() >= 16) {
            query.left(query.length() / 2);
        }

        // Expand to return all Clients for a household
        List<List<SObject>> resultList =
            [FIND :(query + '* OR ' + halfquery + '*') 
                RETURNING Contact( 
                    Name, Id_Number__c, MailingStreet,
                    Account.Name, Account.Id
                WHERE Account.Inactive__c != true 
                ORDER BY Name)];

// TODO: should not need to translate here
        for (sObject obj : resultList[0]) {
            Contact rec = (Contact)obj;
            ClientHousehold chh = new ClientHousehold();
            chh.id = rec.Account.Id;
            chh.contactid = rec.Id;

            // name and addr are displayed in UI for selection
            chh.name = rec.Name;
            chh.addr = rec.MailingStreet;

            chh.value = 
                ((rec.Id_Number__c != null) ? (' (' + rec.Id_Number__c + ')') : '')
                + ((rec.MailingStreet != null) ? (' (' + rec.MailingStreet + ')') : '');

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
    public static Id logVisit( Id hhId, Id contactId, String boxType, Decimal checkoutWeight, Integer pointsUsed, Map<String, Integer> commodityUsage, String visitNotes ) {

        // get the HH detail
        Account[] hhs =
            [select Id, Name, Adults__c, Children__c, Infants__c, Seniors__c, Homeless__c, Out_Of_Area__c, Inactive__c
                from Account where id = :hhid];

        if ( hhs.isEmpty() ) {
            throw new FoodBankException('Household not found.');
        }

        Account hh = hhs[0];

        // TODO: validate remaining points? non-negative and under limit (unless setting allows exception)

        // TODO: activate inactive client? or disallow visit?

        // remove the client from checkin list
        Food_Bank_Checkin__c fbc = Food_Bank_Checkin__c.getInstance( hhid );
        if (fbc != null) delete fbc;

        // Validate Contact references are still valid because between the checkin time and log visit the Contact could have been deleted
        list<Contact> c = [select id from Contact where id = :contactid];
        if (c.isEmpty()) {
            contactid = null;
        }
        c = [select id from Contact where id = :fbc.Visitor__c];
        if (c.isEmpty()) {
            fbc.Visitor__c = null;
        }

        // log the visit
        Client_Visit__c cv = new Client_Visit__c(
            Household__c = hh.Id,
            Adults__c = hh.Adults__c,
            Seniors__c = hh.Seniors__c,
            Children__c = hh.Children__c,
            Infants__c = hh.Infants__c,
            Homeless__c = hh.Homeless__c,
            Out_Of_Area__c = hh.Out_Of_Area__c,
            Points_Used__c = pointsUsed,
            Checkout_Weight__c = checkoutWeight,
            Box_Type__c = boxType,
            Notes__c = visitNotes,
            Visit_Date__c = (fbc != null && fbc.Check_In_Time__c != null) ? fbc.Check_In_Time__c : system.now(),
            Visitor__c = (fbc != null && fbc.Visitor__c != null) ? fbc.Visitor__c : contactid
        );
        if (commodityUsage != null && !commodityUsage.isEmpty())
            cv.Commodity_Usage_JSON__c = JSON.serializePretty(commodityUsage);
        insert cv;

        // TODO: recalc and save the remaining points on household
        if (pointsUsed != null && pointsUsed > 0) {}

        return cv.id;
    }
}
