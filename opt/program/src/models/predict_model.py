import pandas as pd
import numpy as np
import keras
import sys 
import pickle
import os

# temporary workaround
import keras.backend.tensorflow_backend as tb
###

prefix = '/' if "IS_CONTAINER" in os.environ else './'
prefix_path = os.path.join(prefix, 'opt/ml')
output_path = os.path.join(prefix_path, 'output')
model_path = os.path.join(prefix_path, 'model')

class ScoringService(object):
    # Where we keep the model when it's loaded
    model = None                

    @classmethod
    def get_model(cls):
        """Get the model object for this instance, loading it if it's not already loaded."""
        if cls.model == None:
            # temporary workaround
            tb._SYMBOLIC_SCOPE.value = True
            ###

            cls.model = keras.models.load_model(os.path.join(model_path, 'model.h5'))
        
        return cls.model

    @classmethod
    def predict(cls, input):
        """For the input, do the predictions and return them.

        Args:
            input (a pandas dataframe): The data on which to do the predictions. There will be
                one prediction per row in the dataframe"""
        model = cls.get_model()
        X_test = cls.reshapeAndNormalizeXValues(input)
        y_test = model.predict(X_test)
        return y_test

    @classmethod
    def reshapeAndNormalizeXValues(cls, array):
        # channels first or last?
        print(array)
        array = array.reshape(array.shape[0], 28, 28, 1)
        array = array.astype( 'float32' )
        array = array / 255.0
        return array

    @classmethod
    def predictFromImage(cls, image):
        return predict(image)

    @classmethod
    def predictFromCSV(cls, csv):
        df = pd.read_csv(csv, header=None)
        y_test = cls.predict(df.values)
        return np.argmax(y_test, axis=1)

    @classmethod
    def predictAndOutputKaggleSubmission(cls, csv):
        df = pd.read_csv(csv, header=None)
        y_test = cls.predict(df.values)
        y_pred = np.argmax(y_test, axis=1)
        length = len(y_pred)
        image_ids = range(1,length+1)
        result = pd.DataFrame({'ImageId': image_ids,'Label': y_pred})
        result.to_csv(os.path.join(output_path, 'submission.csv'), index=False)

if __name__ == '__main__':
    mode = sys.argv[1]
    service = ScoringService()
    args = sys.argv[2:]

    if mode == 'csv':
        func = service.predictFromCSV
    elif mode == 'image':
        func = service.predictFromImage
    elif mode == 'kaggle':
        func = service.predictAndOutputKaggleSubmission

    sys.exit(func(*args))