#!/bin/sh

name=$1

# https://docs.aws.amazon.com/cli/latest/reference/sagemaker/create-endpoint-config.html
aws sagemaker create-endpoint-config \
--endpoint-config-name ${name} \
--production-variants VariantName=${name},ModelName=${name},InitialInstanceCount=1,InstanceType="ml.t2.medium"