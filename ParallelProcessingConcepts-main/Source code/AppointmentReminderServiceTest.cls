@isTest
public class AppointmentReminderServiceTest {
    @isTest
    static void testSendAppointmentReminders() {
        // Create test patients
        List<Patient__c> testPatients = new List<Patient__c>();
        
        // Create two test patients with appointments for tomorrow
        for (Integer i = 0; i < 2; i++) {
            testPatients.add(new Patient__c(
                Name = 'Test Patient ' + i,
                Email__c = 'testpatient' + i + '@example.com',
                Appointment_Date__c = Date.today().addDays(1) // Appointments for tomorrow
            ));
        }
        
        // Insert test patients
        insert testPatients;

        // Call the method to send appointment reminders
        Test.startTest();
        AppointmentPatientSerial.sendAppointmentReminders();
        Test.stopTest();
        
        // Verify that the expected number of emails were sent
        Integer sentEmailCount = Limits.getEmailInvocations();
        System.assertEquals(2, sentEmailCount, 'Two emails should have been sent.');
    }
}