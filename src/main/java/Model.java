
import org.apache.spark.ml.Pipeline;
import org.apache.spark.ml.PipelineModel;
import org.apache.spark.ml.PipelineStage;

import org.apache.spark.ml.classification.*;

import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator;
import org.apache.spark.ml.feature.*;
import org.apache.spark.sql.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Hello

import static org.apache.spark.sql.functions.lit;
import static org.apache.spark.sql.functions.typedLit;

public class Model {

    public static final String MODEL_PATH = "model/ModelTrained";

    public static final String TESTING_DATASET =  "TestingDataset.csv";

    public PipelineModel select_model(int model_pos, Dataset<Row> lbl_ft_df){
        double accuracy =0, f1=0;
        PipelineModel model = null;

        switch(model_pos){
            case 1:

                model = new Pipeline().setStages(new PipelineStage[]{
                        new LogisticRegression()
                                .setMaxIter(80)
                                .setRegParam(0.000001)
                                .setFamily("multinomial")
                                .setStandardization(true)
//                                .setFitIntercept(false)


                }).fit(lbl_ft_df);
                LogisticRegressionModel lrModel = (LogisticRegressionModel) (model.stages()[0]);
                LogisticRegressionTrainingSummary trainingSummary = lrModel.summary();
                accuracy = trainingSummary.accuracy();
                f1 = trainingSummary.weightedFMeasure();

                break;
        }
        if(model != null) {
            System.out.println();
            System.out.println("Training DataSet Metrics ");

            System.out.println("Accuracy: " + accuracy);
            System.out.println("F-1: " + f1);
        }
        return model;
    }

    public void calc_weight(Dataset<Row> df){

    }

    public void classifier(SparkSession spark,  boolean isTraining, int model_pos) {
        try {
            PipelineModel model = null;
            Dataset<Row> results = null;
            if(isTraining) {
                final String TRAINING_DATASET = "TrainingDataset.csv";
                final String VALIDATION_DATASET = "ValidationDataset.csv";
                Dataset<Row> lbl_ft_df = dataFrame(spark, true, TRAINING_DATASET).cache();

                model = select_model(model_pos, lbl_ft_df);

                if(model != null) {
                    Dataset<Row> val_df = dataFrame(spark, true, VALIDATION_DATASET).cache();

                    results = model.transform(val_df);
                    
                    System.out.println("\n Validation Training Set Metrics");
                    results.select("features", "label", "prediction").show(3, false);
                    get_model_metrics(results);

                    model.write().overwrite().save(MODEL_PATH);
                }
            } else{
                System.out.println("TestingDataSet Metrics \n");
                model = PipelineModel.load(MODEL_PATH);
                Dataset<Row> testDf = dataFrame(spark, true, TESTING_DATASET).cache();
                results = model.transform(testDf).cache();
                results.select("features", "label", "prediction").show(3, false);
                get_model_metrics(results);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void get_model_metrics(Dataset<Row> predictions) {
        System.out.println();
        MulticlassClassificationEvaluator evaluator = new MulticlassClassificationEvaluator();
        evaluator.setMetricName("accuracy");
        System.out.println("The accuracy of the model is " + evaluator.evaluate(predictions));
        evaluator.setMetricName("f1");
        double f1 = evaluator.evaluate(predictions);
        System.out.println("F1: " + f1);
    }

    public Dataset<Row> scaling(Dataset<Row> df){
        String in_col ="features",out_col = "scaled"+in_col;
        StandardScaler scaler = new StandardScaler()
                .setInputCol(in_col)
                .setOutputCol(out_col)
                .setWithStd(true)
                .setWithMean(true);

        MaxAbsScaler scaler1 = new MaxAbsScaler()
                .setInputCol(in_col)
                .setOutputCol(out_col);

        MinMaxScaler scaler2 = new MinMaxScaler()
                .setInputCol(in_col)
                .setOutputCol(out_col);

        StandardScalerModel scalerModel = scaler.fit(df);

//        MaxAbsScalerModel scalerModel = scaler1.fit(df);

//        MinMaxScalerModel scalerModel = scaler2.fit(df);


        Dataset<Row> dataFrame = scalerModel.transform(df).drop(in_col).withColumnRenamed(out_col,in_col);
        System.out.println("Non-scaled df");
        df.show(3);
        System.out.println("Scaled df");
        dataFrame.show(3);
        return dataFrame;

    }

    public Dataset<Row> dataFrame(SparkSession spark, boolean transform, String file_name) {

        Dataset<Row> lbl_ft_df = null;
        try {
            Dataset<Row> df = spark.read().format("csv").option("header", "true")
                    .option("multiline", true).option("sep", ",").option("quote", "\"")
                    .option("dateFormat", "M/d/y").option("inferSchema", true).load(file_name);


            df = df.withColumnRenamed("fixed acidity", "fixed_acidity")
                    .withColumnRenamed("volatile acidity", "volatile_acidity")
                    .withColumnRenamed("citric acid", "citric_acid")
                    .withColumnRenamed("residual sugar", "residual_sugar")
                    .withColumnRenamed("free sulfur dioxide", "free_sulfur_dioxide")
                    .withColumnRenamed("total sulfur dioxide", "total_sulfur_dioxide")
                    .withColumnRenamed("quality", "label");

            lbl_ft_df = df.select("label", "alcohol", "sulphates", "pH",
                    "density", "free_sulfur_dioxide", "total_sulfur_dioxide", "chlorides", "residual_sugar",
                    "citric_acid", "volatile_acidity", "fixed_acidity").na().drop().cache();

//            double total = lbl_ft_df.count();
//
//            Map<Integer, Double> hm = new HashMap<Integer, Double>();
//
//            for(int i=1;i<=10;i++)  hm.put(i,  1.0);

//            List<Row> rowslist = lbl_ft_df.groupBy("label").count().collectAsList();
//            for(int i=0;i<rowslist.size();i++){
//                int lbl = (int) rowslist.get(i).get(0);
//                long val = (long) rowslist.get(i).get(1);
//                double val1 = val / total;
//                hm.put(lbl,val1);
//            }
//            System.out.println(hm);


            VectorAssembler assembler =
                    new VectorAssembler().setInputCols(new String[]{"alcohol", "sulphates", "pH", "density",
                            "free_sulfur_dioxide", "total_sulfur_dioxide", "chlorides", "residual_sugar",
                            "citric_acid", "volatile_acidity", "fixed_acidity"}).setOutputCol("features");

            if (transform)
                lbl_ft_df = assembler.transform(lbl_ft_df).select("label", "features");

//            List<Row> lbls = lbl_ft_df.select("label").collectAsList();
//
//            List<Double> weights = new ArrayList<Double>();
//
//            for(int i=0;i<lbls.size();i++){
//                weights.add(hm.get(lbls.get(i).get(0)));
//            }
//            System.out.println(weights);
//            lbl_ft_df = lbl_ft_df.withColumn("weight_col", typedLit(weights.toArray()));
            lbl_ft_df.show(10);

        }catch (Exception e){
            e.printStackTrace();
        }
        return lbl_ft_df;
    }



    public void add_col(Row row){
        
    }

}
