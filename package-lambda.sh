#!/bin/bash

# Set variables
LAMBDA_DIR="lambda-function"
ZIP_FILE="lambda_function.zip"

# Remove any existing zip file
rm -f ${ZIP_FILE}

# Create a zip file containing the lambda function code and dependencies
cd ${LAMBDA_DIR}
npm install
zip -r ../${ZIP_FILE} *
cd ..