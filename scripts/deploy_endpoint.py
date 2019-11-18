import boto3
import re
import os
import sys
import numpy as np
import pandas as pd
import sagemaker as sage
from sagemaker.predictor import csv_serializer
from time import gmtime, strftime

prefix = '/' if "IS_CONTAINER" in os.environ else './'
data_path = os.path.join(prefix, 'opt/ml/input/data')

def main(image_name, s3_bucket_prefix, iam_role):

    print(os.getcwd())

    # start the sagemaker session
    sess = sage.Session()

    # upload training data to s3
    # print('uploading data to s3...')
    # WORK_DIRECTORY = './opt/ml/input/data/processed'
    # data_location = sess.upload_data(WORK_DIRECTORY, key_prefix=s3_bucket_prefix)
    # print('upload completed')
    # print(data_location)

    data_location = "s3://sagemaker-us-east-2-117588387775"

    # run the container in ecr (estimator) and train the model
    account = sess.boto_session.client('sts').get_caller_identity()['Account']
    region = sess.boto_session.region_name
    image = '{}.dkr.ecr.{}.amazonaws.com/{}:latest'.format(account, region, image_name)

    model = sage.estimator.Estimator(image,
                        iam_role, 1, 'ml.c4.2xlarge',
                        output_path="s3://{}/output".format(sess.default_bucket()),
                        sagemaker_session=sess)

    print('starting model training...')
    model.fit(data_location)
    print('training completed')

    # create predictor from the model (endpoint) and deploy it
    print('deploying predictor...')
    predictor = model.deploy(1, 'ml.t2.medium', serializer=csv_serializer)

    # grab some sample data
    shape = pd.read_csv(os.path.join(data_path, "test/mnist_sample.csv"), header=None)
    shape.drop(shape.columns[[0]],axis=1,inplace=True)
    sample = shape.sample(3)

    # make sure the predictor is working
    print('predictions:')
    print(predictor.predict(sample.values).decode('utf-8'))

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])