from sklearn import tree
import numpy as np
import pandas as pd
import os

prefix = '/' if "IS_CONTAINER" in os.environ else './'
data_path = os.path.join(prefix, 'opt/ml/input/data')
train_path = os.path.join(data_path, 'processed')

def main():
    train_data = pd.read_csv(os.path.join(train_path, 'iris.csv'))

    # labels are in the first column
    train_y = train_data.ix[:,0]
    train_X = train_data.ix[:,1:]

    # Now use scikit-learn's decision tree classifier to train the model.
    model = tree.DecisionTreeClassifier(max_leaf_nodes=10)
    model = model.fit(train_X, train_y)

    return model 

if __name__ == "__main__":
    main()