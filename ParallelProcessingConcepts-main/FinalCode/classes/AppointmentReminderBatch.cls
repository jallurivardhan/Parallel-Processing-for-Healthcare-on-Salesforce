global class AppointmentReminderBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for patients with appointments tomorrow
        return Database.getQueryLocator([ 
            SELECT Id, Name, Email__c, Appointment_Date__c, Status_c__c, Email_Sent_c__c, Description__c
            FROM Patient__c 
            WHERE Appointment_Date__c = :Date.today().addDays(1) 
            AND Status_c__c = 'New' 
            AND Email__c != NULL 
            AND Email_Sent_c__c = false
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Patient__c> patientsToUpdate = new List<Patient__c>();

        for (SObject s : scope) {
            Patient__c patient = (Patient__c)s;

            // Prepare email to send
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { patient.Email__c });
            email.setSubject('Appointment Reminder');
            email.setPlainTextBody('Hello ' + patient.Name + ',\n\n' +
                                   'This is a reminder for your appointment scheduled for tomorrow, ' +
                                   patient.Appointment_Date__c.format() + '.\n\n' +
                                   'Thank you!');
            emails.add(email);
            
            // Mark the patient record as having had the email sent
            patient.Email_Sent_c__c = true;
            patientsToUpdate.add(patient);
        }

        // Send all the emails in one batch
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

        // Update all patient records
        if (!patientsToUpdate.isEmpty()) {
            update patientsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optionally log completion
    }

    global void execute(SchedulableContext SC) {
        // Schedule the batch execution
        Database.executeBatch(this, 10); // Set the batch size as needed
    }
}