# full-stack-mlops
Using MNIST to build a sample full stack work flow for data science &amp; application dev teams.

## Getting Started

### Environment

Create a `.env` file in the root directory of the project and add the following environment variables like so:

``` bash
# Better to not use underscores
export PROJECT_NAME = ml-foo

# S3 bucket
export S3_BUCKET = my-bucket-name

# IAM Role with sagemaker permissions
export IAM_ROLE = arn:aws:iam::XXXXXXXXXXXX:role/service-role/AmazonSageMaker-ExecutionRole-XXXXXXXXXXXXXXX

# AWS profile
export PROFILE = default
```

Then run `make environment`.

Activate your environment.

I can be certain this works if you use `conda` and `python3`.  Though the project supports `python2` and `pip`.


### Dependencies

Workflow project dependencies live in `requirements.txt`

Dependencies to be containerized with the ML application live in `opt/program/requirements.txt`

Run `make requirements` to install them all locally into your enviroment.


### Data

At this time, our MNIST data comes from Kaggle and you need to install the Kaggle CLI to get it:

Please review the Kaggle setup instructions at https://github.com/Kaggle/kaggle-api#api-credentials"

Once you've completed this run `make data`

Then you'll be able to find your data at `opt/program/data/external`


### Features

Do any data pre processing and transformation in `opt/program/src/features/build_features.py`

When you're ready, run `make features`

Your output will be in `opt/program/data/processed`


### Local Training

Build your model in `opt/program/src/models/build_model.py`

Train it by running `make train`

Your output will be at `opt/program/output/models`


### Local Inference

Put your inference logic in `opt/program/src/models/predict_model.py`

Get your predictions by running `make predict METHOD=<method parameter> TEST_FILE=<local file location>`

For example: `make predict METHOD=kaggle TEST_FILE=data/test/mnist_sample.csv`. The path will be prefixed with `opt/program`.

You can keep your test files in `opt/program/data/test`

There are 3 methods to choose for local inference:
- `kaggle` - will produce a csv file at `opt/program/output/submission.csv` in kaggle submission format
- `csv` - get multiple inferences from a csv file
- `image` - get an inference by supplying an actual image (in progress)


### Building the Container's Image

To containerize your model project run `make build_container`


### Locally Testing the Container

1. First, test that your container can train by running `make train_local`
2. Second, to serve the container locally run `make serve_local`
3. Last, make an inference to the container by running `make predict_local`


### Starting With the AWS CLI

From here we'll be working with AWS

You'll need to [install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and then [configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)

Don't forget to set your profile name in your `.env` file (or just leave your AWS profile name as 'default')


### Deploying the Container's Image

After succesfully testing your container, deploy it to AWS's ECR by running `make push_container`


### Data in the Cloud

If you don't have one ready to use, do the very easy step of [creating an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html)

Don't forget to set your bucket name in your `.env` file

Once you're all set, sync the data you prepared earlier to S3 by running `make sync_to_s3`

*To be continued...*
