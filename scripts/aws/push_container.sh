#!/usr/bin/env bash

source scripts/aws/get_image_uri.sh ${name}

# If the repository doesn't exist in ECR, create it.

aws ecr describe-repositories --repository-names "${name}" > /dev/null 2>&1

if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${name}" > /dev/null
fi

# Get the login command from ECR and execute it directly
$(aws ecr get-login --region ${region} --no-include-email)

# Tag the already built docker image and then push it to ECR with the full name.

docker tag ${name} ${image}
docker push ${image}
