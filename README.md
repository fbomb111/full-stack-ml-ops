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

If you don't have docker setup and installed on your machine, do so now.  [Get started here with Docker.](https://docs.docker.com/get-docker/)

I can be certain this works if you use `conda` and `python3`.  Though the project should support `python2` and `pip`.
[Get started here with Anaconda](https://docs.anaconda.com/anaconda/install/)

Then run `make environment`.  Then activate your environment.


### Dependencies

Workflow project dependencies live in `requirements.txt`

Dependencies to be containerized with the ML application live in `opt/program/requirements.txt`

Run `make requirements` to install them all locally into your enviroment.

**At this time 4/7/20 you can safely ignore the following error messages**
```
ERROR: botocore 1.15.38 has requirement docutils<0.16,>=0.10, but you'll have docutils 0.16 which is incompatible.
ERROR: awscli 1.18.38 has requirement docutils<0.16,>=0.10, but you'll have docutils 0.16 which is incompatible.
```


### Data

At this time, our MNIST data comes from Kaggle and you need to install the Kaggle CLI to get it:

Please review the Kaggle setup instructions at https://github.com/Kaggle/kaggle-api#api-credentials"

Once you've completed this run `make data`

Then you'll be able to find your data at `opt/ml/input/data/external`

**At this time 4/7/20 the data downloads as a zip file and you must manually unzip the folders yourself before moving on to the next step.**


### Features

Do any data pre processing and transformation in `opt/program/src/features/build_features.py`

When you're ready, run `make features`

Your output will be in `opt/ml/input/data/processed`


### Local Training

Build your model in `opt/program/src/models/build_model.py`

Train it by running `make train`. If you run this 'as-is' the default is set to run for only 1 epoch.

Your output will be in `opt/ml/model`


### Local Inference

Put your inference logic in `opt/program/src/models/predict_model.py`

Get your predictions by running `make predict METHOD=<method-parameter> TEST_FILE=<local-file-location>`

For example: `make predict METHOD=csv TEST_FILE=opt/ml/input/data/test/mnist_sample.csv`.  
You should see the output [2 0 9] which are the three predictions for each row in the mnist_sample.csv test file.

For convenience, you can keep your test files in `opt/ml/input/data/test`

There are 3 methods to choose for local inference:
- `kaggle` - will produce a csv file at `opt/program/output/submission.csv` in kaggle submission format
- `csv` - get multiple inferences from a csv file
- `image` - get an inference by supplying an actual image (**not current working!**)


### Building the Container's Image

To containerize your model project run `make build_container`
This will run the steps found in the Dockerfile which includes setting up dependencies and environment variables.

**At this time 4/7/20 you should be able to ignore the following error messages**
```
Successfully built pyyaml absl-py gast wrapt termcolor
ERROR: google-auth 1.13.1 has requirement setuptools>=40.3.0, but you'll have setuptools 39.0.1 which is incompatible.
ERROR: tensorboard 2.1.1 has requirement setuptools>=41.0.0, but you'll have setuptools 39.0.1 which is incompatible.
ERROR: tensorflow 2.1.0 has requirement six>=1.12.0, but you'll have six 1.11.0 which is incompatible.
```

### Locally Testing the Container

1. First, test that your container can train by running `make train_local`
2. Second, to serve the container locally run `make serve_local`
- Assuming you've done all this in a terminal window, you'll want to open a new terminal tab/window to the same directory and input the next command.
3. Last, make an inference to the container by running `make predict_local TEST_FILE=<local-file-location>`
- i.e. `make predict_local TEST_FILE=opt/ml/input/data/test/mnist_sample.csv`.
4. It's safe to stop your container now.


### Getting Started with the AWS CLI

From here we'll be working with AWS

You'll need to [install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and then [configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)

**Note:** Don't forget to set your profile name in your `.env` file (or just leave your AWS profile name as 'default')


### Deploying the Container's Image

After succesfully testing your container, before deploying, you can clear out all the assets you created while testing by running `make purge`.  
This will delete your docker image and all your data assets.  Then run `make build_container` so you can push a lighter weight version.
Deploy it to AWS's ECR by running `make push_container`.

**I don't know why these images are enormous.  Plan on this taking a substantial amount of time to push the container to ECR until I can fix this**



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


### Creating a Training Job With SageMaker

By this point you should have:
1) An IAM Role
2) A S3 bucket
3) A docker image in AWS ECR

For optional advanced customization you can tune hyperparameters and input data channels at `opt/ml/input/config/hyperparameters.json`

**Note:** Training costs $ unless you use free tier resources.  However, you will only be billed to the closest second for the actual time needed to train.  Billing will end as soon as training is completed.

Run `make create_training_job` to train your model.

When complete, you'll find your model in S3 at `<your-bucket>/output/<training-job-name>/output/model.tar.gz`


### Creating a Model with SageMaker

Run `make create_model`


### Creating an Endpoint Configuration with SageMaker

Run `make create_endpoint_config`


### Creating an Endpoint with SageMaker

Run `make create_endpoint`

**Note:** Deploying an endpoint costs $ unless you use free tier resources.  Because the endpoints needs to stay available on a running EC2, you will continue to be billed even if not using the endpoint.  To prevent further charges, you must delete the endpoint.


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
