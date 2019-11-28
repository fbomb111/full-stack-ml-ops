# This is the file that implements a flask server to do inferences. It's the file that you will modify to
# implement the scoring for your own algorithm.

from __future__ import print_function

import numpy as np
import os, sys, re, io, base64
from PIL import Image
from flask import request

import pickle
from io import StringIO
import signal
import traceback
import flask
import pandas as pd
import keras
from opt.program.src.models.predict_model import ScoringService

# temporary workaround
import keras.backend.tensorflow_backend as tb
###

app = flask.Flask(__name__)

prefix = '/' if "IS_CONTAINER" in os.environ else './'

prefix_path = os.path.join(prefix, 'opt/ml/')
output_path = os.path.join(prefix_path, 'output')
model_path = os.path.join(prefix_path, 'model')

@app.route('/index', methods=['POST'])
def index():

    res = {"result": 0,
        "data": [], 
        "error": ''}

    # converts image data from the request and decodes base64 to an image
    imgData = request.get_data()
    imgData1 = imgData.decode("utf-8")
    img_str = re.search(r'base64,(.*)',imgData1).group(1)
    image_bytes = io.BytesIO(base64.b64decode(img_str))
    im = Image.open(image_bytes)

    # Resize image to 28x28
    im = im.resize((28,28))

    # don't quite understand, but the shape is 28, 28, 4 and this converts it to 28, 28, 1?
    # is this just manipulating the channels?
    arr = np.array(im)[:,:,0:1]

    # returns a multi dimensional array of predictions, but for this example we assume you only want one/the first prediction
    probs = ScoringService.predictFromImage(arr).tolist()[0]

     # Return json data
    res['result'] = 1
    res['data'] = probs

    return flask.jsonify(res)

@app.route('/ping', methods=['GET'])
def ping():
    """Determine if the container is working and healthy. In this sample container, we declare
    it healthy if we can load the model successfully."""
    health = ScoringService.get_model() is not None  # You can insert a health check here

    status = 200 if health else 404
    return flask.Response(response='\n', status=status, mimetype='application/json')

@app.route('/invocations', methods=['POST'])
def transformation():

    """Do an inference on a single batch of data. In this sample server, we take data as CSV, convert
    it to a pandas data frame for internal use and then convert the predictions back to CSV (which really
    just means one prediction per line, since there's a single column.
    """
    data = None

    # Convert from CSV to pandas
    if flask.request.content_type == 'text/csv':
        data = flask.request.data.decode('utf-8')
        s = StringIO(data)
    else:
        return flask.Response(response='This predictor only supports CSV data', status=415, mimetype='text/plain')

    predictions = ScoringService.predictFromCSV(s)

    # Convert from numpy back to CSV
    out = StringIO()
    pd.DataFrame({'results':predictions}).to_csv(out, header=False, index=False)
    result = out.getvalue()

    return flask.Response(response=result, status=200, mimetype='text/csv')

if __name__ == '__main__':
	# run!
	app.run()