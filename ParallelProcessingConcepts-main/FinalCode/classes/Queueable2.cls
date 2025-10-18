public class Queueable2 implements Queueable {
    public static void execute(QueueableContext qc){
        Database.executeBatch(new AppointmentCompleteBatch());
    }
}