#!/bin/sh

name=$1
role=$2

# https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html
aws lambda create-function \
    --function-name ${name} \
    --runtime python3.7 \
    --zip-file fileb://scripts/aws/lambda_function.py.zip \
    --handler lambda_function.lambda_handler \
    --environment Variables={ENDPOINT_NAME=${name}} \
    --publish \
    --role ${role}