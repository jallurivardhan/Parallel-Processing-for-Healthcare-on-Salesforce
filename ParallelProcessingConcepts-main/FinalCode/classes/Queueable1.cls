public class Queueable1 implements Queueable {
    public static void execute(QueueableContext qc){
         Database.executeBatch(new AppointmentAdmitBatch());
         System.enqueueJob(new Queueable2());
         System.debug('batch started');
    }
}