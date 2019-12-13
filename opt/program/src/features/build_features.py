import os

prefix = '/' if "IS_CONTAINER" in os.environ else './'
data_path = os.path.join(prefix, 'opt/ml/input/data')
train_path = os.path.join(data_path, 'processed')

def main():
    print('no features to build')

if __name__ == "__main__":
    main()