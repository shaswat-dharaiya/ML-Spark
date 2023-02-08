# #!/bin/bash

bucket_name=ml-train1

aws s3 cp s3://$bucket_name/training.tar ~/training.tar
tar -xvzf ~/training.tar --directory ~/
mv ~/target/MLTrain_Trainer-1.0-SNAPSHOT.jar ~/MLTrain_Trainer-1.0-SNAPSHOT.jar
mv ~/dataset/* ~/