import os, sys, copy, json
import boto3
import sagemaker as sage
from sagemaker.amazon.amazon_estimator import get_image_uri
from time import gmtime, strftime

prefix = '/' if "IS_CONTAINER" in os.environ else './'
data_path = os.path.join(prefix, 'opt/ml/input/data')
config_path = os.path.join(prefix, 'opt/ml/input/config')

def main(image_name, s3_bucket, iam_role):

    sess = sage.Session()
    sm = boto3.Session().client('sagemaker')
    account = sess.boto_session.client('sts').get_caller_identity()['Account']
    region = sess.boto_session.region_name
    image = '{}.dkr.ecr.{}.amazonaws.com/{}:latest'.format(account, region, image_name)

    # training job params
    training_job_name = image_name + strftime("%Y-%m-%d-%H-%M-%S", gmtime())
    print("Job name is:", training_job_name)

    training_job_params = {}
    training_job_params["AlgorithmSpecification"] = {"TrainingImage": image, "TrainingInputMode": "File"}
    training_job_params["TrainingJobName"] = training_job_name
    training_job_params["ResourceConfig"] = {"InstanceCount": 1, "InstanceType": "ml.m4.xlarge", "VolumeSizeInGB": 5}
    training_job_params["RoleArn"] = iam_role
    training_job_params["OutputDataConfig"] = {"S3OutputPath": "s3://" + s3_bucket + "/output"}
    training_job_params["StoppingCondition"] = {"MaxRuntimeInSeconds": 86400}

    # input config says what s3 data channels should be copied to the container
    inputDataConfigFile = os.path.join(config_path, 'inputdataconfig.json')
    with open(inputDataConfigFile) as json_file:
        training_job_params["InputDataConfig"] = json.load(json_file)

    # sets the s3 path for each channel
    for index, channel in enumerate(["/processed", "/external", "/test"]):
        path = "s3://" + s3_bucket + "/input" + channel
        training_job_params["InputDataConfig"][index]["DataSource"]["S3DataSource"]["S3Uri"] = path

    # sets hyper params for the training job
    hyperParamsConfigFile = os.path.join(config_path, 'hyperparameters.json')
    with open(hyperParamsConfigFile) as json_file:
        training_job_params["HyperParameters"] = json.load(json_file)

    sm.create_training_job(**training_job_params)

    # give us some feedback
    status = sm.describe_training_job(TrainingJobName=training_job_name)['TrainingJobStatus']
    print(status)
    sm.get_waiter('training_job_completed_or_stopped').wait(TrainingJobName=training_job_name)
    status = sm.describe_training_job(TrainingJobName=training_job_name)['TrainingJobStatus']
    print("Training job ended with status: " + status)
    if status == 'Failed':
        message = sm.describe_training_job(TrainingJobName=training_job_name)['FailureReason']
        print('Training failed with the following error: {}'.format(message))
        raise Exception('Training job failed')

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])