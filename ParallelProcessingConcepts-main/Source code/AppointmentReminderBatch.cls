global class AppointmentReminderBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for patients with appointments tomorrow
        return Database.getQueryLocator([
            SELECT Id, Name, Email__c, Appointment_Date__c
            FROM Patient__c
            WHERE Appointment_Date__c = :Date.today().addDays(1)
            AND Email__c != NULL
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (SObject s : scope) {
            Patient__c patient = (Patient__c)s;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { patient.Email__c });
            email.setSubject('Appointment Reminder');
            email.setPlainTextBody('Hello ' + patient.Name + ',\n\n' +
                                    'This is a reminder for your appointment scheduled for tomorrow, ' +
                                    patient.Appointment_Date__c.format() + '.\n\n' +
                                    'Thank you!');
            emails.add(email);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
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