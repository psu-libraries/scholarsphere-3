#!/bin/bash

echo "Making dependency cache directory"
mkdir -p dep_cache
ls -l dep_cache

echo "Installing AWS command line tools"
pip install awscli --upgrade --user

echo "Installing PhantomJS"
export PATH=$PWD/travis_phantomjs/phantomjs-2.1.1-linux-x86_64/bin:$PATH
which phantomjs
phantomjs --version
if [ $(phantomjs --version) != '2.1.1' ]; then rm -rf $PWD/travis_phantomjs; mkdir -p $PWD/travis_phantomjs; fi
if [ $(phantomjs --version) != '2.1.1' ]; then wget https://assets.membergetmember.co/software/phantomjs-2.1.1-linux-x86_64.tar.bz2 -O $PWD/travis_phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2; fi
if [ $(phantomjs --version) != '2.1.1' ]; then tar -xvf $PWD/travis_phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C $PWD/travis_phantomjs; fi
phantomjs --version

echo "Install Code Climate test reporting tool"
curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
chmod +x ./cc-test-reporter

echo "Configuring Scholarsphere for test"
export PATH=$PATH:$(pwd)/fits
cp config/travis/solr_wrapper_test.yml config/solr_wrapper_test.yml
cp config/travis/fcrepo_wrapper_test.yml config/fcrepo_wrapper_test.yml
cp config/sample/application.yml config/application.yml
cp config/sample/database.yml config/database.yml
cp config/sample/hydra-ldap.yml config/hydra-ldap.yml
cp config/sample/share_notify.yml config/share_notify.yml
cp config/sample/initializers/qa.rb config/initializers/qa.rb

echo "Listing Redis information"
redis-cli info

echo "Prepare coverage report and run the RSpec test"
./cc-test-reporter before-build
bundle exec rake scholarsphere:travis:$TEST_SUITE

echo "Upload coverage results to AWS"
./cc-test-reporter format-coverage --output coverage/codeclimate.$TRAVIS_BUILD_ID.$TEST_SUITE.json
aws s3 sync coverage/ s3://psu.edu.scholarsphere-qa/coverage/$TRAVIS_BUILD_NUMBER
