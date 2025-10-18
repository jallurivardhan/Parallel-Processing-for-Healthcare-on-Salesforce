global class AppointmentCompleteBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for patients with appointments today
        return Database.getQueryLocator([ 
            SELECT Id, Name, Email__c, Appointment_Date__c, Status_c__c, Admit__c, Email_Sent_c__c, Description__c
            FROM Patient__c 
            WHERE Appointment_Date__c = :Date.today() 
            AND Status_c__c = 'Scheduled' 
            AND Admit__c = false
            AND Email__c != NULL 
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Patient__c> patientsToUpdate = new List<Patient__c>();
        
        for (SObject s : scope) {
            Patient__c patient = (Patient__c)s;
                 
			patient.Status_c__c ='Completed';
            patientsToUpdate.add(patient);
        }
        
        // Send the emails if there are any
        
        // Update the patients' Email_Sent__c status to 'Yes'
        if (!patientsToUpdate.isEmpty()) {
            update patientsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optionally log completion
    }

    global void execute(SchedulableContext SC) {
        // Schedule the batch execution
        Database.executeBatch(this, 5); // Set the batch size as needed
    }
}