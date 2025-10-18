@isTest
public class AppointmentCompleteBatchTest {

    @isTest
    static void testAppointmentCompleteBatch() {
        // Create test patient records
        List<Patient__c> patients = new List<Patient__c>();
        
        for (Integer i = 0; i < 5; i++) {
            patients.add(new Patient__c(
                Name = 'Test Patient ' + i,
                Appointment_Date__c = Date.today(),
                Status_c__c = 'Scheduled',
                Email__c = 'test' + i + '@example.com',
                Email_Sent_c__c = true,
                Admit__c = false,
                Description__c = 'Test Appointment'
            ));
        }
        
        // Insert the test records
        insert patients;
        
        // Check that the patients were inserted correctly
        System.assertEquals(5, [SELECT COUNT() FROM Patient__c WHERE Appointment_Date__c = :Date.today()]);

        // Instantiate the batch class
        AppointmentCompleteBatch batch = new AppointmentCompleteBatch();
        
        // Execute the batch job
        Test.startTest();
        Database.executeBatch(batch, 10); // Executes with a batch size of 10
        Test.stopTest();
        
        // Verify that the patients' Status_c__c was updated to 'Complete'
        List<Patient__c> updatedPatients = [SELECT Id, Status_c__c, Email_Sent_c__c,Admit__c FROM Patient__c WHERE Appointment_Date__c = :Date.today()];
        
        for (Patient__c patient : updatedPatients) {
            System.assertEquals('Completed', patient.Status_c__c, 'The status should be updated to Completed');
            System.assertEquals(true, patient.Email_Sent_c__c, 'The Email_Sent_c__c field should be updated to Yes');
        }
    }
}