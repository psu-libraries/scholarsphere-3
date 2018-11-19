#!/bin/bash

echo -e "\n\n\033[0;32mTravis test.sh script\033[0m"

echo -e "\n\n\033[1;33mMaking dependency cache directory\033[0m"
mkdir -p dep_cache
echo "Listing directory contents:"
ls -l dep_cache

echo -e "\n\n\033[1;33mInstalling AWS command line tools\033[0m"
pip install awscli --upgrade --user

echo -e "\n\n\033[1;33mInstalling Code Climate test reporting tool\033[0m"
if [ ! -f dep_cache/cc-test-reporter ]; then
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./dep_cache/cc-test-reporter
  chmod +x ./dep_cache/cc-test-reporter
fi
export PATH=$PATH:$(pwd)/dep_cache

echo -e "\n\n\033[1;33mConfiguring Scholarsphere for test\033[0m"
export PATH=$PATH:$(pwd)/fits
cp config/travis/solr_wrapper_test.yml config/solr_wrapper_test.yml
cp config/travis/fcrepo_wrapper_test.yml config/fcrepo_wrapper_test.yml
cp config/sample/database.yml config/database.yml
cp config/sample/hydra-ldap.yml config/hydra-ldap.yml
cp config/sample/share_notify.yml config/share_notify.yml
cp config/sample/initializers/qa.rb config/initializers/qa.rb
cp config/travis/application_test.yml config/application.yml

echo -e "\n\n\033[1;33mListing Redis information\033[0m"
redis-cli info

echo -e "\n\n\033[1;33mStart python for testing\033[0m"
cd public
python -m SimpleHTTPServer 8000 &
cd ..

echo -e "\n\n\033[1;33mStart Chrome for headless testing\033[0m"
google-chrome-stable --headless --disable-gpu --remote-debugging-port=9222 http://localhost &

echo -e "\n\n\033[1;33mPrepare coverage report and run the RSpec test\033[0m"
cc-test-reporter before-build
bundle exec rake scholarsphere:travis:$TEST_SUITE
RSPEC_EXIT_CODE=$?

echo -e "\n\n\033[1;33mUpload coverage results to AWS\033[0m"
cc-test-reporter format-coverage --output coverage/codeclimate.$TRAVIS_BUILD_ID.$TEST_SUITE.json
aws s3 sync coverage/ s3://psu.edu.scholarsphere-qa/coverage/$TRAVIS_BUILD_NUMBER

exit $RSPEC_EXIT_CODE
