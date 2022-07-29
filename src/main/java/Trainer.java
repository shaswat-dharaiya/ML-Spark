
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.spark.sql.SparkSession;
import java.io.File;

public class Trainer {

    public static final String APP_NAME = "Wine-quality-prediction";

    public static final String TRAINING_DATASET = "TrainingDataset.csv";

    public static void main(String[] args) {

        Logger.getLogger("org").setLevel(Level.ERROR);

        SparkSession spark = SparkSession.builder()
                .appName(APP_NAME)
                .master("local[*]")
                .config("spark.executor.memory", "2147480000")
                .config("spark.driver.memory", "2147480000")
                .config("spark.testing.memory", "2147480000")
                .getOrCreate();

        File tempFile = new File(TRAINING_DATASET);
        boolean exists = tempFile.exists();
        Model model = new Model();

        if (exists)
            model.classifier(spark, true,1);
        else
            System.out.print("TrainingDataset.csv doesn't exists");

        spark.stop();
    }
}