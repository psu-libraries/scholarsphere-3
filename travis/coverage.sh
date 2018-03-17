#!/bin/bash

echo "Installing AWS and Code Climate tools, and sending coverage report"
pip install awscli --upgrade --user
curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
chmod +x ./cc-test-reporter
aws s3 sync s3://psu.edu.scholarsphere-qa/coverage/$TRAVIS_BUILD_NUMBER coverage/
./cc-test-reporter sum-coverage --output - --parts 2 coverage/codeclimate.*.json | ./cc-test-reporter upload-coverage --input -
