#!/bin/sh

name=$1
payload=$2

json="{ \"data\" : \"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,17,17,17,17,81,180,180,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,139,253,253,253,253,253,253,253,48,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,228,253,253,253,253,253,253,253,207,197,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,213,253,253,253,253,253,253,253,253,253,253,223,52,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,66,231,253,253,253,108,40,40,115,244,253,253,134,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,114,114,114,37,0,0,0,205,253,253,253,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,57,253,253,253,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,42,253,253,253,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,95,253,253,253,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,205,253,253,253,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,61,99,96,0,0,45,224,253,253,195,10,0,0,0,0,0,0,0,0,0,0,0,11,25,105,83,189,189,228,253,251,189,189,218,253,253,210,27,0,0,0,0,0,0,0,0,0,0,42,116,173,253,253,253,253,253,253,253,253,253,253,253,253,253,221,116,7,0,0,0,0,0,0,0,0,0,118,253,253,253,253,245,212,222,253,253,253,253,253,253,253,253,253,253,160,15,0,0,0,0,0,0,0,0,254,253,253,253,189,99,0,32,202,253,253,253,240,122,122,190,253,253,253,174,0,0,0,0,0,0,0,0,255,253,253,253,238,222,222,222,241,253,253,230,70,0,0,17,175,229,253,253,0,0,0,0,0,0,0,0,158,253,253,253,253,253,253,253,253,205,106,65,0,0,0,0,0,62,244,157,0,0,0,0,0,0,0,0,6,26,179,179,179,179,179,30,15,10,0,0,0,0,0,0,0,0,14,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,29,85,85,85,85,85,85,85,85,71,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,107,128,168,250,250,250,252,250,250,250,250,231,127,63,0,0,0,0,0,0,0,0,0,0,0,0,85,168,237,252,250,250,250,250,252,250,250,250,250,252,250,209,56,0,0,0,0,0,0,0,0,0,0,0,127,250,250,252,250,250,250,250,252,250,250,250,250,252,250,250,83,0,0,0,0,0,0,0,0,0,8,113,252,252,252,247,210,210,210,210,177,0,0,0,0,43,252,252,83,0,0,0,0,0,0,0,0,0,43,250,250,250,250,210,0,0,0,0,0,0,0,0,0,28,194,250,138,14,0,0,0,0,0,0,0,0,43,250,250,250,250,210,0,0,0,0,0,0,0,0,0,0,85,250,250,41,0,0,0,0,0,0,0,0,43,250,250,137,83,70,0,0,0,0,0,0,0,0,0,0,28,167,250,41,0,0,0,0,0,0,0,0,219,250,144,14,0,0,0,0,0,0,0,0,0,0,0,0,0,127,250,217,0,0,0,0,0,0,0,0,254,238,105,0,0,0,0,0,0,0,0,0,0,0,0,0,15,148,252,252,0,0,0,0,0,0,0,0,252,166,0,0,0,0,0,0,0,0,0,0,0,0,0,85,140,250,250,179,0,0,0,0,0,0,0,0,252,208,63,0,0,0,0,0,0,0,0,0,0,85,127,252,250,250,250,41,0,0,0,0,0,0,0,0,252,250,209,56,0,0,0,0,0,141,170,168,168,223,250,252,250,250,137,14,0,0,0,0,0,0,0,0,252,250,250,223,210,212,210,210,210,244,252,250,250,250,250,252,250,144,14,0,0,0,0,0,0,0,0,0,43,252,252,252,252,254,252,252,252,252,255,252,252,252,217,177,0,0,0,0,0,0,0,0,0,0,0,0,28,166,208,250,250,252,250,250,250,250,238,166,166,166,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,125,125,146,250,250,165,125,105,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,83,83,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,100,213,254,245,255,149,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,181,233,102,40,29,102,166,187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,57,236,181,35,0,0,0,0,12,207,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,27,228,187,0,0,0,0,0,0,96,225,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,167,230,18,0,0,0,0,0,74,242,106,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,83,247,60,0,0,0,0,0,67,232,102,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,133,211,0,0,0,0,16,127,225,165,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,133,217,0,15,58,140,189,181,227,24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,71,246,225,235,253,182,61,231,85,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,73,143,119,58,1,153,212,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,88,254,69,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,40,244,157,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,212,211,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,95,237,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43,243,156,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,213,213,5,0,0,0,0,0,6,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,163,244,35,0,0,0,0,0,0,139,208,97,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,248,90,0,0,0,0,0,0,0,16,136,172,168,0,0,0,0,0,0,0,0,0,0,0,0,0,5,195,147,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,237,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\" }"

# var=$(tr '\n' '\\n' < $payload)

# echo "$var"

# json=$(echo "{ \"data\": \"$var\"}")

# echo "$json"

# https://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html
aws lambda invoke \
    --function-name ${name} \
    --payload "$json" \
    opt/ml/output/lambda_test.json