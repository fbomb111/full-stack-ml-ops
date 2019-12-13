#!/bin/sh

name=$1

# create a trust policy for sagemaker.amazonaws.com
# https://docs.aws.amazon.com/cli/latest/reference/iam/create-role.html
role_arn=$(aws iam create-role --role-name ${name}-Role --assume-role-policy-document file://./scripts/aws/trust-policy.json --query 'Role.Arn')

if [ $? -eq 0 ]
then

# remove double quotes
role_arn=$(echo $role_arn | xargs)

# easy-append ARN to .env file
echo "
# IAM Role with sagemaker permissions
export IAM_ROLE = $role_arn" >>.env   

# attach the SageMaker & Lambda policies
# https://docs.aws.amazon.com/cli/latest/reference/iam/attach-role-policy.html
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess --role-name ${name}-Role
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name ${name}-Role
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name ${name}-Role

fi