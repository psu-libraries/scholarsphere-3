#!/bin/bash

if [ "$RAILS_ENV" == "production" ]; then
    envconsul -vault-token=$(cat /etc/token/.vault-token) -secret="$VAULT_KEY_PATH" -no-prefix -once ./run.sh
else
    ./run.sh
fi