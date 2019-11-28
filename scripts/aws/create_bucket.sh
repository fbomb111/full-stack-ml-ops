#!/bin/sh

name=$1
profile=$2

region=$(aws configure get region --profile ${profile})

aws s3api create-bucket --bucket ${name}-bucket --region $region --create-bucket-configuration LocationConstraint=$region

if [ $? -eq 0 ]
then
# easy-append ARN to .env file
echo "
# S3 Bucket
export S3_BUCKET = ${name}-bucket" >>.env  
fi