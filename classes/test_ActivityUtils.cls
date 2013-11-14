@isTest(seeAllData = true)
private class test_ActivityUtils {
    
    static testMethod void mainTest() {
        Account a = new Account();
        a.Name = 'Test Account';
        a.Industry = 'Other';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Joe';
        c.LastName = 'Smith';
        c.AccountId = a.Id;
        c.Email = 'test@test.com';
        insert c;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.StageName = 'Open';
        o.CloseDate = Date.today() + 7;
        o.Name = 'Test Opp';
        insert o;
        
        Lead l = new Lead();
        l.LeadSource = 'Other';
        l.FirstName = 'Joe';
        l.LastName = 'Smith';
        l.Industry = 'Other';
        l.Status = 'New Lead';
        l.Company = 'Test Co';
        insert l;
        
        Task[] tList = new list<Task>();
        Event[] eList = new list<Event>();
        for(Integer i=0; i<4; i++) {
            Task t = new Task();
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.Type = 'Scheduled Call Back';
            if(i==0) t.WhatId = a.Id;
            if(i==1) t.WhatId = o.Id;
            if(i==2) t.WhoId = c.Id;
            if(i==3) t.WhoId = l.Id;
            tList.add(t);
            
            Event e = new Event();
            e.StartDateTime = DateTime.now() + 7;
            e.EndDateTime = DateTime.now() + 14;
            if(i==0) e.WhatId = a.Id;
            if(i==1) e.WhatId = o.Id;
            if(i==2) e.WhoId = c.Id;
            if(i==3) e.WhoId = l.Id;
            eList.add(e);
        }
        insert tList;
        insert eList;
        
        test.startTest();
            system.assertEquals(6, [SELECT Open_Activity_Count__c FROM Account WHERE Id = :a.Id].Open_Activity_Count__c);
            system.assertEquals(2, [SELECT Open_Activity_Count__c FROM Opportunity WHERE Id = :o.Id].Open_Activity_Count__c);
            system.assertEquals(2, [SELECT Open_Activity_Count__c FROM Contact WHERE Id = :c.Id].Open_Activity_Count__c);
            system.assertEquals(2, [SELECT Open_Activity_Count__c FROM Lead WHERE Id = :l.Id].Open_Activity_Count__c);
            
            //Delete some activities and run assertions again
            delete eList;
            system.assertEquals(3, [SELECT Open_Activity_Count__c FROM Account WHERE Id = :a.Id].Open_Activity_Count__c);
            system.assertEquals(1, [SELECT Open_Activity_Count__c FROM Opportunity WHERE Id = :o.Id].Open_Activity_Count__c);
            system.assertEquals(1, [SELECT Open_Activity_Count__c FROM Contact WHERE Id = :c.Id].Open_Activity_Count__c);
            system.assertEquals(1, [SELECT Open_Activity_Count__c FROM Lead WHERE Id = :l.Id].Open_Activity_Count__c);
        test.stopTest();

    }
    
}