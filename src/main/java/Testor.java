
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.spark.sql.SparkSession;

import java.io.File;

public class Testor {

    public static final String APP_NAME = "Wine-quality-prediction";
    public static final String TESTING_DATASET =  "TestingDataset.csv";

    public static void main(String[] args) {

        Logger.getLogger("org").setLevel(Level.ERROR);
        Logger.getLogger("akka").setLevel(Level.ERROR);
        Logger.getLogger("breeze.optimize").setLevel(Level.ERROR);
        Logger.getLogger("com.amazonaws.auth").setLevel(Level.DEBUG);
        Logger.getLogger("com.github").setLevel(Level.ERROR);


        SparkSession spark = SparkSession.builder()
                .appName(APP_NAME)
                .master("local[*]")
                .config("spark.executor.memory", "2147480000")
                .config("spark.driver.memory", "2147480000")
                .config("spark.testing.memory", "2147480000")
                .getOrCreate();

        File tempFile = new File(TESTING_DATASET);
        boolean exists = tempFile.exists();
        Model model = new Model();

        if(exists)
            model.classifier(spark, false,0);
        else
            System.out.print("TestingData.csv not found\n");

        spark.stop();
    }
}
