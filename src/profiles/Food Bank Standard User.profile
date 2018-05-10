<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>Food_Bank_Service</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>
    <classAccesses>
        <apexClass>FoodBankHouseholds</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankHouseholdsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankManager</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankManagerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankSettings</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankStats</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankStatsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankTrigger</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>FoodBankTriggerTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <custom>true</custom>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Adults__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Box_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Checkout_Weight__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Children__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Commodity_Usage_JSON__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.External_Created_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.External_Household_Id__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.External_Id__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.First_Visit_This_Year__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Client_Visit__c.Homeless_Counter__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Homeless__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Infants__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Client_Visit__c.More_Than_One_Person__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Notes__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Client_Visit__c.Out_Of_Area_Counter__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Out_Of_Area__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Points_Used__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Seniors__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Client_Visit__c.Total_People__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Visit_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Visit_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Client_Visit__c.Visitor__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>Client_Visit__c-Client Visit Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Global-Global Layout</layout>
    </layoutAssignments>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>Client_Visit__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>Account</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <pageAccesses>
        <apexPage>FoodBankApp</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>FoodBankStats</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>JasmineTestRunner</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
    <userLicense>Salesforce</userLicense>
    <userPermissions>
        <enabled>true</enabled>
        <name>AddDirectMessageMembers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApexRestServices</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiEnabled</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterEditOwnPost</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterFileLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInternalUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInviteExternalUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterOwnGroups</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ContentWorkspaces</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ConvertLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CustomizeApplication</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DistributeFromPersWksp</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditEvent</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditOppLineItemUnitPrice</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTask</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailMass</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailSingle</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableCommunityAppLauncher</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableNotifications</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ExportReport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ImportPersonal</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningConsoleAllowedForUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningExperienceUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ListEmailSend</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCustomPermissions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageTranslation</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MassInlineEdit</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RemoveDirectMessageMembers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RunReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SelectFilesFromSalesforce</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SendSitRequests</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ShowCompanyNameAsUserBadge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubmitMacrosAllowed</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeToLightningReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>UseWebLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHelpLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewRoles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewSetup</name>
    </userPermissions>
</Profile>
