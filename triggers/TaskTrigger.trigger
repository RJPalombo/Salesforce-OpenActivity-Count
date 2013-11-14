trigger TaskTrigger on Task (after insert, after update, after delete, after undelete) {
    
    sObject[] triggerRecords;
    if(!trigger.isDelete) triggerRecords = trigger.new;
    else triggerRecords = trigger.old;
    
    //Update Open Activity Count
    ActivityUtils au = new ActivityUtils(triggerRecords);
    au.updateAccountActivityCount();
    au.updateContactActivityCount();
    au.updateLeadActivityCount();
    au.updateOpportunityActivityCount();
    
}