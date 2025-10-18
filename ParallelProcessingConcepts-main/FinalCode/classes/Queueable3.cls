public class Queueable3 implements Queueable {
    public static void execute(QueueableContext qc){
       Database.executeBatch(new AppointmentAdmitBatch());
        System.debug('batch started');
    }
}