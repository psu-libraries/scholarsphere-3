#!/bin/bash
#
# Stops and then starts resque-pool in either production or development environment 
# script/restart_resque.sh [production|development] 

RESQUE_POOL_PIDFILE="$(pwd)/tmp/pids/resque-pool.pid"
HOSTNAME=$(hostname -s)
ENVIRONMENT=$1
function anywait {
    for pid in "$@"; do
        while kill -0 "$pid"; do
            sleep 0.5
        done
    done
}

function banner {
    echo -e "$0 ↠ $1"
}

if [ $# -eq 0 ]; then
    echo -e "ERROR: no environment argument [production|development] provided" 
    exit 1
fi

if [ $ENVIRONMENT != "production" ] && [ $ENVIRONMENT != "development" ]; then 
    echo -e "ERROR: environment argument must be either [production|development] most likely this will be development for local machines and production otherwise" 
    exit 1
fi

banner "killing resque-pool"
[ -f $RESQUE_POOL_PIDFILE ] && {
    PID=$(cat $RESQUE_POOL_PIDFILE)
    kill -2 $PID && anywait $PID
}
banner "starting resque-pool"
bundle exec resque-pool --daemon --environment $ENVIRONMENT start
