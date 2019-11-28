#!/bin/sh

name=$1

# https://docs.aws.amazon.com/cli/latest/reference/sagemaker/describe-training-job.html
output=$(aws sagemaker describe-training-job \
    --training-job-name $name \
    --query '{S3ModelArtifacts:ModelArtifacts.S3ModelArtifacts,TrainingImage:AlgorithmSpecification.TrainingImage,RoleArn:RoleArn}')

image=$(echo "$output" | sed -n -e 's/^.*\TrainingImage": "\(.*\)".*$/\1/p')
model=$(echo "$output" | sed -n -e 's/^.*\S3ModelArtifacts": "\(.*\)".*$/\1/p')
role=$(echo "$output" | sed -n -e 's/^.*\RoleArn": "\(.*\)".*$/\1/p')

# https://docs.aws.amazon.com/cli/latest/reference/sagemaker/create-model.html
aws sagemaker create-model \
    --model-name $name \
    --primary-container Image=$image,ModelDataUrl=$model \
    --execution-role-arn $role