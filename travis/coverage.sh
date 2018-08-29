#!/bin/bash

echo -e "\n\n\033[0;32mTravis coverage.sh script\033[0m"

echo -e "\n\n\033[1;33mInstalling AWS command line tools\033[0m"
pip install awscli --upgrade --user

echo -e "\n\n\033[1;33mInstalling Code Climate test reporting tool\033[0m"
if [ ! -f dep_cache/cc-test-reporter ]; then
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./dep_cache/cc-test-reporter
  chmod +x ./dep_cache/cc-test-reporter
fi
export PATH=$PATH:$(pwd)/dep_cache

echo -e "\n\n\033[1;33mSending combined report to Code Climate\033[0m"
aws s3 sync s3://psu.edu.scholarsphere-qa/coverage/$TRAVIS_BUILD_NUMBER coverage/
cc-test-reporter sum-coverage --output - --parts 4 coverage/codeclimate.*.json | cc-test-reporter upload-coverage --input -
