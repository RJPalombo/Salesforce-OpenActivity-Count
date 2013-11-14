public class ActivityUtils {

    //config
    String fieldToUpdate = 'Open_Activity_Count__c'; //this field must be added to each object we're updating

    //state
    set<Id> accountIds;
    set<Id> contactIds;
    set<Id> opportunityIds;
    set<Id> leadIds;
    
    public ActivityUtils(sObject[] records) {
        accountIds = new set<Id>();
        contactIds = new set<Id>();
        opportunityIds = new set<Id>();
        leadIds = new set<Id>();
        captureWhatAndWhoIds(records);
        addAccountIdsFromRlatedObjects();
    }
    
    public void updateAccountActivityCount() {
        if(accountIds.size() == 0) return;
        updateActivityCount('Account','WhatId', getStringFromIdSet(accountIds));
    }
    public void updateContactActivityCount() {
        if(contactIds.size() == 0) return;
        updateActivityCount('Contact','WhoId', getStringFromIdSet(contactIds));
    }
    public void updateOpportunityActivityCount() {
        if(opportunityIds.size() == 0) return;
        updateActivityCount('Opportunity','WhatId', getStringFromIdSet(opportunityIds));
    }
    public void updateLeadActivityCount() {
        if(leadIds.size() == 0) return;
        updateActivityCount('Lead','WhoId', getStringFromIdSet(leadIds));
    }
    private void updateActivityCount(String objToUpdate, String queryFld, String updateIds) {
        string strQuery = 'SELECT Id, (SELECT Id FROM OpenActivities) FROM ' + objToUpdate + ' WHERE Id IN (' + updateIds + ')';
        sObject[] sobjects = new list<sObject>();
        for(sObject so : database.query(strQuery)) {
            OpenActivity[] oActivities = so.getSObjects('OpenActivities');
            Integer openActivityCount = oActivities == null ? 0 : oActivities.size();
            sObject obj = createObject(objToUpdate, so.Id);
            obj.put(fieldToUpdate, openActivityCount);
            sobjects.add(obj);
            system.debug('openActivityCount: ' + openActivityCount);
        }
        update sobjects;
    }
    
    private void captureWhatAndWhoIds(sObject[] objects) {
        for(sObject o : objects) {
            Id whatId = (Id)o.get('WhatId');
            Id whoId = (Id)o.get('WhoId');
            if(whatId != null) {
                String objectName = getObjectNameFromId(whatId);
                if(objectName == 'account') accountIds.add(whatId);
                if(objectName == 'opportunity') opportunityIds.add(whatId);
            }
            if(whoId != null) {
                String objectName = getObjectNameFromId(whoId);
                if(objectName == 'contact') contactIds.add(whoId);
                if(objectName == 'lead') leadIds.add(whoId);
            }
        }
    }
    
    private void addAccountIdsFromRlatedObjects() {
        for(Opportunity o : [SELECT AccountId FROM Opportunity WHERE Id IN :opportunityIds]) accountIds.add(o.AccountId);
        for(Contact c : [SELECT AccountId FROM Contact WHERE Id IN :contactIds]) accountIds.add(c.AccountId);
    }
    
    private String getObjectNameFromId(Id objId) {
        String preFix = String.valueOf(objId).left(3).toLowercase();
        if(prefix == '001') return 'account';
        if(prefix == '003') return 'contact';
        if(prefix == '006') return 'opportunity';
        if(prefix == '00q') return 'lead';
        return '';
    }
    
    private String getStringFromIdSet(set<Id> idSet) {
        string idString = '';
        for(Id i : idSet) idString+= '\'' + i + '\',';
        return idString == '' ? idString : idString.left(idString.length()-1); //If idString contains some ids we want to ensure we strip out the last comma
    }
    
    //The main part of the method below was taken from //Taken from http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_dynamic_dml.htm
    //However we've modified this to accept an object id
    private sObject createObject(String typeName, Id objId) { 
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
        }
        
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(objId); 
    }

}