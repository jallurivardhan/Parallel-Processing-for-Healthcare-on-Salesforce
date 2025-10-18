@isTest
private class AppointmentReminderBatchTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test patients with appointments
        List<Patient__c> testPatients = new List<Patient__c>();
        
        // Create patients for different scenarios
        // Patients with appointments tomorrow
        testPatients.add(new Patient__c(
            Name = 'Test Patient 1',
            Email__c = 'patient1@test.com',
            Appointment_Date__c = Date.today().addDays(1),
            Status_c__c = 'New',
            Email_Sent_c__c = false
        ));
        
        // Patient with appointment tomorrow but already emailed
        testPatients.add(new Patient__c(
            Name = 'Test Patient 2',
            Email__c = 'patient2@test.com',
            Appointment_Date__c = Date.today().addDays(1),
            Status_c__c = 'New',
            Email_Sent_c__c = true
        ));
        
        // Patient with appointment on a different date
        testPatients.add(new Patient__c(
            Name = 'Test Patient 3',
            Email__c = 'patient3@test.com',
            Appointment_Date__c = Date.today().addDays(2),
            Status_c__c = 'New',
            Email_Sent_c__c = false
        ));
        
        // Patient without email
        testPatients.add(new Patient__c(
            Name = 'Test Patient 4',
            Email__c = null,
            Appointment_Date__c = Date.today().addDays(1),
            Status_c__c = 'New',
            Email_Sent_c__c = false
        ));
        
        insert testPatients;
    }
    
    @isTest
    static void testBatchAppointmentReminder() {
        Test.startTest();
        
        // Create and execute the batch job
        AppointmentReminderBatch batch = new AppointmentReminderBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Verify emails and updates
        List<Patient__c> updatedPatients = [
            SELECT Id, Email_Sent_c__c 
            FROM Patient__c 
            WHERE Appointment_Date__c = :Date.today().addDays(1) 
            AND Status_c__c = 'New' 
            AND Email__c != NULL
        ];
        
        // Assert that the correct number of patients were updated
        System.assertEquals(1, updatedPatients.size(), 'Only one patient should have been processed');
        System.assert(updatedPatients[0].Email_Sent_c__c, 'Email sent flag should be true');
    }
    
    @isTest
    static void testScheduledBatch() {
        Test.startTest();
        
        // Schedule the batch job
        String cronExp = '0 0 0 * * ?'; // Run daily at midnight
        System.schedule('Test Appointment Reminder', cronExp, new AppointmentReminderBatch());
        
        Test.stopTest();
        
        // No direct assertions needed for scheduling
    }
    
    @isTest
    static void testEmailSending() {
        Test.startTest();
        
        // Create a mock email
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'test@example.com' });
        email.setSubject('Test Email');
        email.setPlainTextBody('Test Body');
        emails.add(email);
        
        // Use a mock email method to simulate sending
        Messaging.sendEmail(emails);
        
        Test.stopTest();
        
        // No assertions needed - this is just to ensure email sending works
    }
}