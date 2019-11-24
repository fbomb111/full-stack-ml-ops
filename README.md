# full-stack-mlops
Using MNIST to build a sample full stack work flow for data science &amp; application dev teams.

## Getting Started

### Environment

Create a `.env` file in the root directory of the project and add the following environment variables like so:

``` bash
# Better to not use underscores in the name
export PROJECT_NAME = ml-foo

# AWS profile
export PROFILE = default
```

Then run `make environment`.  Activate your environment.
I can be certain this works if you use `conda` and `python3`.  Though the project supports `python2` and `pip`.


### Dependencies

Workflow project dependencies live in `requirements.txt`

Dependencies to be containerized with the ML application live in `opt/program/requirements.txt`

Run `make requirements` to install them all locally into your enviroment.


### Data

At this time, our MNIST data comes from Kaggle and you need to install the Kaggle CLI to get it:

Please review the Kaggle setup instructions at https://github.com/Kaggle/kaggle-api#api-credentials"

Once you've completed this run `make data`

Then you'll be able to find your data at `opt/ml/input/data/external`


### Features

Do any data pre processing and transformation in `opt/program/src/features/build_features.py`

When you're ready, run `make features`

Your output will be in `opt/ml/input/data/processed`


### Local Training

Build your model in `opt/program/src/models/build_model.py`

Train it by running `make train`

Your output will be in `opt/ml/model`


### Local Inference

Put your inference logic in `opt/program/src/models/predict_model.py`

Get your predictions by running `make predict METHOD=<method-parameter> TEST_FILE=<local-file-location>`

For example: `make predict METHOD=kaggle TEST_FILE=opt/ml/input/data/test/mnist_sample.csv`.

For convenience, you can keep your test files in `opt/ml/input/data/test`

There are 3 methods to choose for local inference:
- `kaggle` - will produce a csv file at `opt/program/output/submission.csv` in kaggle submission format
- `csv` - get multiple inferences from a csv file
- `image` - get an inference by supplying an actual image (in progress)


### Building the Container's Image

To containerize your model project run `make build_container`


### Locally Testing the Container

1. First, test that your container can train by running `make train_local`
2. Second, to serve the container locally run `make serve_local`
3. Last, make an inference to the container by running `make predict_local TEST_FILE=<local-file-location>`


### Getting Started with the AWS CLI

From here we'll be working with AWS

You'll need to [install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and then [configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)

**Note:** Don't forget to set your profile name in your `.env` file (or just leave your AWS profile name as 'default')


### Deploying the Container's Image

After succesfully testing your container, deploy it to AWS's ECR by running `make push_container`


### Data in the Cloud

If you already have a bucket you'd like to use with SageMaker, add the bucket name manually to you `.env` like so:

`export S3_BUCKET = <your-bucket-name>`

**OR** If you don't have a bucket you can run `make create_bucket`.  Your `.env` file will be updated automatically.  Your bucket in S3 will be given the name `<project-name>-Bucket`.  Optionally call `make create_bucket S3_BUCKET=<your-bucket-name>` to give a name other than the project name.

**OR** Read the docs to [create an S3 bucket here](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html)

Once you're all set, sync the data you prepared earlier to S3 by running `make sync_to_s3`

Your data for the `external`, `processed`, and `test` channels will now appear in S3 under `<your-bucket-name>/input`


### Creating the IAM Role

If you already have an IAM role ready for use with SageMaker, get the ARN of the role and add a line manually to your `.env` file like so:

`export IAM_ROLE = arn:aws:iam::XXXXXXXXXXXX:role/<rest-of-your-arn>`

**OR** - If you don't yet have a role you can run `make create_role`.  Your `.env` file will be updated automatically.  Your role in IAM will be given the name `<project-name>-Role`

**OR** - Read the docs to [get started with creating your own role here:](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html)


### Training & Deploying the Model & Endpoint With Sagemaker

By this point you should have:
1) An IAM Role
2) A S3 bucket
3) A docker image in AWS ECR

For optional advanced customization you can tune hyperparameters and input data channels at `scripts/train_and_deploy.py`

**Note:** Both training and deploying the endpoint cost $ unless you use free tier resources.  For training, you will only be billed to the closest second for the actual time needed to train.  However, for deploying the endpoint, you will be billed as long as the endpoint is available, even if you're not using it.  Therefore, the default below is to train only.

Create and train the model with Sagemaker by running `make train_and_deploy`.  If you'd like to also deploy an endpoint, run `make train_and_deploy TRAIN_ONLY=False` instead

When complete, you'll find your model in S3 at `<your-bucket>/output/<training-job-name>/output/model.tar.gz`


### Using Lambda to Access Your Endpoint

In order to send requests to your model and get back predections we'll use AWS's Lambda service.

Run `make create_lambda` to deploy a lambda function.

Read more on Lambda [here in the AWS docs](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html).


### Test Your Lambda Function

To ensure your lambda function works, you can send a sample csv to lambda and get back the results.

Run `make test_lambda TEST_FILE=<local-file-location>`.  For example: `make test_lambda TEST_FILE=opt/ml/input/data/test/mnist_sample.csv`.

The results of your request will be written to the file at `opt/ml/output/lambda_test.json`.


### Using the API Gateway to Access Your Endpoint Externally

*To be continued...*


# Resources

https://github.com/awslabs/amazon-sagemaker-examples

https://sagemaker-workshop.com/custom/containers.html

https://drivendata.github.io/cookiecutter-data-science/