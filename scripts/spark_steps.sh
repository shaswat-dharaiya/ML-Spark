echo "Starting Steps"

hadoop fs -put ~/TrainingDataset.csv
hadoop fs -put ~/ValidationDataset.csv

hdfs dfs -ls -t -R

echo "Hadoop put"

spark-submit ~/MLTrain_Trainer-1.0-SNAPSHOT.jar

hdfs dfs -ls -t -R

echo "Model Trained"

hdfs dfs -copyToLocal model ~/
tar czf model.tar.gz model

aws s3 cp ~/model.tar.gz s3://ml-train1/model.tar.gz

echo "Training Complete"