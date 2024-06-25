trigger FakeStoreTrigger on Fake_Store__c (after insert) {
    for(Fake_Store__c product : Trigger.New) {
        if (!Trigger.New.isEmpty()) {
        // Access the last element in Trigger.New
        Fake_Store__c lastRecord = Trigger.New[Trigger.New.size() - 1];
        
        // Get the Id of the last element
        Id productId = lastRecord.Id;
        
        
        // You can also use this Id in further logic, like making an API call
        FakeStore.createProductInExternalAPI(productId);
    }
    }
}