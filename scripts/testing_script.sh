# #!/bin/bash

sudo apt-get update -y > /dev/null
echo "update complete"
sudo apt install -y awscli > /dev/null
echo "awscli installed"
sudo apt install -y  python3-pip > /dev/null
echo "pip installed"
sudo apt install -y  default-jre > /dev/null
echo "jre installed"
pip3 install py4j > /dev/null
echo "py4j installed"

AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2

echo "key: $1"
echo "secret: $2"

bucket_name=ml-train1 
AWS_REGION="us-east-1" >> /home/ubuntu/.bashrc 

aws configure --profile ml-spark-aws <<-EOF > /dev/null 2>&1
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

wget https://www.scala-lang.org/files/archive/scala-2.12.6.tgz -P /home/ubuntu/ > /dev/null
sudo tar -xvzf /home/ubuntu/scala-2.12.6.tgz --directory /home/ubuntu/
sudo mv /home/ubuntu/scala-2.12.6 /usr/local/share/scala
echo "scala installed"
export SCALA_HOME="/usr/local/share/scala" >> /home/ubuntu/.bashrc 
export PATH="$PATH:$SCALA_HOME/bin" >> /home/ubuntu/.bashrc

# Download Spark to the ec2-user's home directory

wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop2.tgz  -P /home/ubuntu/ > /dev/null

# Unpack Spark in the /opt directory
sudo tar zxvf /home/ubuntu/spark-3.3.1-bin-hadoop2.tgz -C /opt > /dev/null

# Update permissions on installation
sudo chown -R ubuntu:ubuntu /opt/spark-3.3.1-bin-hadoop2

# Create a symbolic link to make it easier to access
sudo ln -fs spark-3.3.1-bin-hadoop2 /opt/spark
echo "spark installed"
# Insert these lines into your /home/ubuntu/.bash_profile:
export SPARK_HOME=/opt/spark >> /home/ubuntu/.bashrc
export PATH=$PATH:$SPARK_HOME/bin >> /home/ubuntu/.bashrc

# Then exit the text editor and return to the command line.

aws s3 cp s3://ml-train1/model.tar.gz /home/ubuntu/model.tar.gz --profile ml-spark-aws

sudo tar -xzvf /home/ubuntu/model.tar.gz --directory /home/ubuntu/ > /dev/null
sudo tar -xzvf /home/ubuntu/testing.tar --directory /home/ubuntu/ > /dev/null

cp ~/target/MLTrain_Testor-1.0-SNAPSHOT.jar ~/MLTrain_Testor-1.0-SNAPSHOT.jar
cp ~/dataset/* ~/

ls -a
source /home/ubuntu/.bashrc

spark-submit MLTrain_Testor-1.0-SNAPSHOT.jar