trigger PatientStatusUpdateTrigger on Patient__c (before update) {
    for (Patient__c p : Trigger.new) {
        // Check if the Email_Sent__c checkbox is true and the status is not already 'Scheduled'
        if (p.Email_Sent_c__c == true && p.Status_c__c != 'Scheduled'  && p.Status_c__c == 'New') {
            p.Status_c__c = 'Scheduled';
        }
    }
}