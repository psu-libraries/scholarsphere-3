#!/bin/bash

echo -e "\n\n\033[0;32mTravis niftany.sh script\033[0m"

echo -e "\n\n\033[1;33mRunning Rubocop\033[0m"
bundle exec rubocop
RUBOCOP_EXIT_CODE=$?

echo -e "\n\n\033[1;33mRunning erb-lint\033[0m"
bundle exec erblint --lint-all
ERBLINT_EXIT_CODE=$?

if [ ! $RUBOCOP_EXIT_CODE -eq 0 ]; then
  echo -e "\n\n\033[1;Rubocop failed!\033[0m"
  exit $RUBOCOP_EXIT_CODE
fi

if [ ! $ERBLINT_EXIT_CODE -eq 0 ]; then
  echo -e "\n\n\033[1;erb-lint failed!\033[0m"
  exit $ERBLINT_EXIT_CODE
fi
