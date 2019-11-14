import pandas as pd
import numpy as np
import keras
import sys 
import pickle
import os

# temporary workaround
import keras.backend.tensorflow_backend as tb
###

output_path = 'output'
model_path = os.path.join(output_path, 'models')

def predictFromImage(image):
    if os.path.basename(os.path.normpath(os.getcwd())) != 'container':
        os.chdir('container')

    return predict(csv)

def predictFromCSV(csv):
    df = pd.read_csv(csv, header=None)
    y_test = predict(df.values)
    return np.argmax(y_test, axis=1)

def predictAndOutputKaggleSubmission(csv):
    df = pd.read_csv(csv, header=None)
    y_test = predict(df.values)
    y_pred = np.argmax(y_test, axis=1)
    length = len(y_pred)#len(reshapeAndNormalizeXValues(csv))
    image_ids = range(1,length+1)
    result = pd.DataFrame({'ImageId': image_ids,'Label': y_pred})
    result.to_csv(os.path.join(output_path, 'submission.csv'), index=False)

def predict(input):

    # temporary workaround
    tb._SYMBOLIC_SCOPE.value = True
    ###

    X_test = reshapeAndNormalizeXValues(input)
    model = keras.models.load_model(os.path.join(model_path, 'model.h5'))
    y_test = model.predict(X_test)
    return y_test

def reshapeAndNormalizeXValues(array):
    # channels first or last?
    print(array)
    array = array.reshape(array.shape[0], 28, 28, 1)
    array = array.astype( 'float32' )
    array = array / 255.0
    return array

functions = {
    'image': predictFromImage,
    'csv': predictFromCSV,
    'kaggle': predictAndOutputKaggleSubmission
}

if __name__ == '__main__':
    func = functions[sys.argv[1]]
    args = sys.argv[2:]

    sys.exit(func(*args))