import os, sys
import argparse
import sagemaker
from sagemaker.amazon.amazon_estimator import get_image_uri

parser = argparse.ArgumentParser(description='Set bool for endpoint deployment.')
parser.add_argument('params', nargs='+')
parser.add_argument('--train_only', action='store_false')
parser.add_argument('--train_and_deploy', action='store_true')

def main(image_name, s3_bucket, iam_role):

    sess = sagemaker.Session()
    prefix = 'input'

    account = sess.boto_session.client('sts').get_caller_identity()['Account']
    region = sess.boto_session.region_name
    container = '{}.dkr.ecr.{}.amazonaws.com/{}:latest'.format(account, region, image_name)

    data_channels = {}
    for index, channel_name in enumerate(['processed', 'external', 'test']):
        path = 's3://{}/{}/{}'.format(s3_bucket, prefix, channel_name)
        channel = sagemaker.session.s3_input(path, content_type='text/csv')
        data_channels[channel_name] = channel

    s3_output_location = 's3://{}/{}/{}'.format(s3_bucket, prefix, 'model')

    model = sagemaker.estimator.Estimator(container,
                                         iam_role, 
                                         train_instance_count=1, 
                                         train_instance_type='ml.m4.xlarge',
                                         train_volume_size = 5,
                                         output_path=s3_output_location,
                                         sagemaker_session=sagemaker.Session())


    model.set_hyperparameters(max_depth = 5,
                              eta = .2,
                              gamma = 4,
                              min_child_weight = 6,
                              silent = 0,
                              objective = "multi:softmax",
                              num_class = 10,
                              num_round = 10)

    model.fit(inputs=data_channels, logs=True)

    train_and_deploy = parser.parse_args().train_and_deploy
    if train_and_deploy is True:
        predictor = model.deploy(initial_instance_count=1,
                                instance_type='ml.m4.xlarge')

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])