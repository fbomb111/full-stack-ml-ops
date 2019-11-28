#!/bin/sh

name=$1
payload=$2

var=$(tr '\r\n' '\\n' < $payload)
json=$(echo "{ \"data\": \"$var\"}")

# https://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html
aws lambda invoke \
    --function-name ${name} \
    --payload "$json" \
    opt/ml/output/lambda_test.json