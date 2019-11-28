#!/bin/sh

name=$1
bucket=$2
role=$3

source scripts/aws/get_image_uri.sh ${name}

# change the bucket location in inputdataconfig
sed -i '' "s/S3_BUCKET/${bucket}/g" opt/ml/input/config/inputdataconfig.json

starttime=$(date +"%y-%m-%d-%H-%M-%S")
training_name="${name}-$starttime"

# https://docs.aws.amazon.com/cli/latest/reference/sagemaker/create-training-job.html
aws sagemaker create-training-job \
    --training-job-name $training_name \
    --hyper-parameters "$(< opt/ml/input/config/hyperparameters.json)" \
    --algorithm-specification TrainingImage=$image,TrainingInputMode="File" \
    --role-arn ${role} \
    --input-data-config "$(< opt/ml/input/config/inputdataconfig.json)" \
    --output-data-config S3OutputPath="s3://${bucket}/output/model" \
    --resource-config InstanceType="ml.m4.xlarge",InstanceCount=1,VolumeSizeInGB=5 \
    --stopping-condition MaxRuntimeInSeconds=86400 

if [ $? -eq 0 ]
then
# easy-append ARN to .env file
echo "
# Training Job Name
export TRAINING_JOB_NAME = ${training_name}" >>.env 
fi

# change inputdataconfig back to original
sed -i '' "s/${bucket}/S3_BUCKET/g" opt/ml/input/config/inputdataconfig.json