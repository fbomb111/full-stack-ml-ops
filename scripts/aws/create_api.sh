#!/bin/sh

# name=$1
name='Test222'

rest_api_id=$(aws apigateway create-rest-api \
    --name ${name} \
    --description "Lambda endpoint for ${name}" \
    --endpoint-configuration types=REGIONAL\
    --query 'id')


# parent_resource_id=$(aws apigateway get-resources \
#     --rest-api-id ${rest_api_id} \
#     --query 'items[0].id')


# aws apigateway create-resource \
#     --rest-api-id ${rest_api_id} \
#     --parent-id ${parent_resource_id} \
#     --path-part "predict"


# echo $rest_api_id