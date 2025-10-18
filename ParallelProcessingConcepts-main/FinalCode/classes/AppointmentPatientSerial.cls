public class AppointmentPatientSerial {
    static final Integer BATCH_SIZE = 10; // Define your batch size

    public static void sendAppointmentReminders() {
        // Query for patients with appointments tomorrow
        List<Patient__c> patients = [
            SELECT Id, Name, Email__c, Appointment_Date__c
            FROM Patient__c
            WHERE Appointment_Date__c = :Date.today().addDays(1)
            AND Email__c != NULL
        ];

        System.debug('Patients found: ' + patients.size()); // Debug statement

        if (patients.isEmpty()) {
            System.debug('No patients with appointments tomorrow.');
            return;
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Integer emailCount = 0; // Counter for emails sent

        for (Integer i = 0; i < patients.size(); i++) {
            emails.add(createEmail(patients[i]));
            emailCount++;

            // Send emails in batches
            if (emailCount == BATCH_SIZE || i == patients.size() - 1) {
                try {
                    Messaging.sendEmail(emails);
                    System.debug('Batch of emails sent successfully.');
                } catch (Exception e) {
                    System.debug('Error sending emails: ' + e.getMessage());
                }
                emails.clear(); // Clear the list after sending
                emailCount = 0; // Reset counter after sending
            }
        }
    }

    private static Messaging.SingleEmailMessage createEmail(Patient__c patient) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { patient.Email__c });
        email.setSubject('Appointment Reminder');
        email.setPlainTextBody(
            'Hello ' + patient.Name + ',\n\n' +
            'This is a reminder for your appointment scheduled for tomorrow, ' +
            patient.Appointment_Date__c.format() + '.\n\n' +
            'Thank you!'
        );
        return email;
    }
}