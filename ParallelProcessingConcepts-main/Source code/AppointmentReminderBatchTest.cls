@isTest
private class AppointmentReminderBatchTest {
    @isTest
    static void testBatch() {
        // Step 1: Setup test data
        // Create a patient with an appointment for tomorrow and a valid email
        Patient__c testPatient = new Patient__c(
            Name = 'John Doe',
            Email__c = 'john.doe@example.com',
            Appointment_Date__c = Date.today().addDays(1)
        );
        insert testPatient;

        // Step 2: Execute the batch
        Test.startTest();
        AppointmentReminderBatch batch = new AppointmentReminderBatch();
        Database.executeBatch(batch, 10); // Execute with a batch size of 10
        Test.stopTest();

        // Step 3: Validate the outcome
        // Since we can't directly capture sent emails, we can check the debug logs
        // Alternatively, you could use a mock or spy to assert calls made within Messaging class

        // Use a logging mechanism to track if an email was sent
        // This example assumes you have a custom object or some logging mechanism set up
        // You can create an EmailLog__c custom object to store logs for testing purposes

        // For demo purposes, we're using debug statements to ensure execution
        System.debug('Batch executed successfully for patient: ' + testPatient.Name);
    }

    @isTest
    static void testBatchWithNoAppointments() {
        // Step 1: No patients have appointments tomorrow, so no setup needed

        // Step 2: Execute the batch
        Test.startTest();
        AppointmentReminderBatch batch = new AppointmentReminderBatch();
        Database.executeBatch(batch, 10);
        Test.stopTest();

        // Step 3: Since there are no appointments, we expect no logs or actions
        System.debug('Batch executed successfully with no appointments.');
    }
}