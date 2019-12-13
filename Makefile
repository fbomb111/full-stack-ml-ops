
include .env

.PHONY: clean data lint requirements sync_to_s3 sync_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON_INTERPRETER = python3

# name that docker will use for creating the image which will also be uploaded to AWS ECR
DOCKER_IMAGE_NAME = $(PROJECT_NAME)
DOCKER_IMAGE_NAME_IS_VALID := $(shell [[ $(DOCKER_IMAGE_NAME) =~ ^[a-zA-Z0-9](-*[a-zA-Z0-9])*$$ ]] && echo TRUE || echo FALSE)
DOCKER_IMAGE_EXISTS := $(shell docker images -q $(DOCKER_IMAGE_NAME))

# This should be passed in with the command line argument for predict and predict_local
METHOD=csv
TEST_FILE=opt/ml/input/data/test/mnist_sample.csv 

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install Python Dependencies
requirements: test_environment
# If conda is not installing pip packages into your actual conda env...
# Try running 'path/to/condaenv/bin/pip install -r requirements.txt' manually.  
# It seems it'll work fine after that.
# Make sure 'which pip' is returning the conda path, not your system path
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	# install application dependencies
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt	
	# install project dependencies
	$(PYTHON_INTERPRETER) -m pip install -r opt/program/requirements.txt	

## Make Dataset
data: opt/ml/input/data/external/train.csv opt/ml/input/data/external/test.csv

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

# Delete all output files (data, models, kaggle csv)
purge:
	find opt/ml/output -type f -delete
	find opt/ml/model -type f -delete
	find opt/ml/input/data/external -type f -delete
	find opt/ml/input/data/processed -type f -delete

## Lint using flake8
lint:
	flake8 src

## Upload Data to S3
sync_to_s3:
ifeq (default,$(PROFILE))
	aws s3 sync opt/ml/input/data/ s3://$(S3_BUCKET)/input/
else
	aws s3 sync opt/ml/input/data/ s3://$(S3_BUCKET)/input/ --profile $(PROFILE)
endif

## Download Data from S3
sync_from_s3:
ifeq (default,$(PROFILE))
	aws s3 sync s3://$(S3_BUCKET)/input/ opt/ml/input/data/
else
	aws s3 sync s3://$(S3_BUCKET)/input/ opt/ml/input/data/ --profile $(PROFILE)
endif

## Set up python interpreter environment
environment:
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	# As of now, higher versions of python don't support tensorflow
	conda create --name $(PROJECT_NAME) python=3.7 pip 
else
	conda create --name $(PROJECT_NAME) python=2.7 pip
endif
	@echo ">>> New conda env created. Activate with:\nsource activate $(PROJECT_NAME)"
else
	$(PYTHON_INTERPRETER) -m pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already installed.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@sh -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

features: 
	$(PYTHON_INTERPRETER) opt/program/src/features/build_features.py

train: 
	$(PYTHON_INTERPRETER) opt/program/train

# example: make predict METHOD=csv TEST_FILE=opt/ml/input/data/test/mnist_sample.csv
predict: 
	$(PYTHON_INTERPRETER) opt/program/src/models/predict_model.py $(METHOD) $(TEST_FILE); exit 0 

submit: ~/.kaggle/kaggle.json opt/ml/input/data/processed/submission.csv
	kaggle competitions submit digit-recognizer -f opt/program/output/submission.csv -m "Automated submission"
	echo "All submissions:"
	kaggle competitions submissions digit-recognizer

grade: opt/ml/input/data/processed/submission.csv
	$(PYTHON_INTERPRETER) test/test_project.py

~/.kaggle/kaggle.json:
	@echo "Configuration error. Please review the Kaggle setup instructions at https://github.com/Kaggle/kaggle-api#api-credentials"; exit 1;

opt/ml/input/data/external/train.csv: ~/.kaggle/kaggle.json
	kaggle competitions download -c digit-recognizer -f train.csv --unzip -p opt/ml/input/data/external --force

opt/ml/input/data/external/test.csv: ~/.kaggle/kaggle.json
	kaggle competitions download -c digit-recognizer -f test.csv --unzip  -p opt/ml/input/data/external --force

opt/ml/model/model.h5: train

opt/ml/input/data/processed/submission.csv: predict

opt/ml/input/data/processed/X_train.npy: features

opt/ml/input/data/processed/X_test.npy: features

opt/ml/input/data/processed/y_train.npy: features

opt/ml/input/data/processed/y_test.npy: features

#################################################################################
# DEPLOYMENT COMMANDS                                                           #
#################################################################################

build_container:
	sh scripts/build_container.sh $(DOCKER_IMAGE_NAME)

train_local: 
ifeq ($(DOCKER_IMAGE_NAME_IS_VALID),)
	@echo "Image name * $(DOCKER_IMAGE_NAME) * failed to satisfy constraint: Member must satisfy regular expression pattern: ^[a-zA-Z0-9](-*[a-zA-Z0-9])*"
else ifeq ($(DOCKER_IMAGE_EXISTS),)
	@echo "Image name * $(DOCKER_IMAGE_NAME) * not found.  Run 'make build_container' to create the image"
else
	opt/program/local_test/train_local.sh $(DOCKER_IMAGE_NAME)
endif

serve_local:
	opt/program/local_test/serve_local.sh $(DOCKER_IMAGE_NAME)

# EXAMPLE: make predict_local TEST_FILE=opt/ml/input/data/test/mnist_sample.csv
predict_local:
	opt/program/local_test/predict_local.sh $(TEST_FILE)

push_container:
	sh scripts/aws/push_container.sh $(DOCKER_IMAGE_NAME)

# EXAMPLE: make create_bucket S3_BUCKET=sagemaker-byo-mnist
create_bucket:
ifeq (,$(S3_BUCKET))
	sh scripts/aws/create_bucket.sh $(PROJECT_NAME) $(PROFILE)
else
	sh scripts/aws/create_bucket.sh $(S3_BUCKET) $(PROFILE)
endif

create_role:
	sh scripts/aws/create_iam_role.sh $(PROJECT_NAME)

# IMPORTANT: creating a training job costs $, though billing will automatically stop as soon as training is complete.
create_training_job:
	sh scripts/aws/create_training_job.sh $(DOCKER_IMAGE_NAME) $(S3_BUCKET) $(IAM_ROLE)

create_model:
	sh scripts/aws/create_model.sh $(TRAINING_JOB_NAME) 

create_endpoint_config:
	sh scripts/aws/create_endpoint_config.sh $(TRAINING_JOB_NAME) 

# IMPORTANT: deploying an endpoint costs $ even when you're not using it, so delete it if you don't need it
create_endpoint:
	sh scripts/aws/create_endpoint.sh $(TRAINING_JOB_NAME) 

create_lambda:
	sh scripts/aws/create_lambda.sh $(TRAINING_JOB_NAME) $(IAM_ROLE)

# EXAMPLE: make test_lambda TEST_FILE=opt/ml/input/data/test/mnist_sample.csv
test_lambda:
	sh scripts/aws/invoke_lambda.sh $(TRAINING_JOB_NAME) $(TEST_FILE)

walkoff_deploy: data features train build_container push_container create_training_job

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
