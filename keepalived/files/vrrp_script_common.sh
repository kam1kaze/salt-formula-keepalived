#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

proc_name="$1" # Example: 'haproxy'
restart_command="${2:-NONE}" # Example: 'service haproxy restart'
wait_seconds="${3:-1}" # how long checks the process after restart atempt

function check_service() {
  pidof "$1"
}

function logging() {
  logger -t "keepalived_vrrp_script[$$]" "$1"
}

if ! check_service "$proc_name"; then

  # tring to fix proxy server if neccessary
  if [[ "$restart_command" != 'NONE' ]]; then
    logging "NOTICE: could not find running '${proc_name}' process, executing '${restart_command}'"
    $restart_command
    for ((s=0; s <= wait_seconds; s++)); do
      sleep $s
      if check_service "$proc_name"; then
        logging "OK: process '$proc_name' succesfully started"
        exit 0
      fi
    done
    logging "FAIL: process '$proc_name' could not be started after $wait_seconds seconds"
    exit 1
  fi

  # return erorr
  logging "FAIL: process '$proc_name' is not running"
  exit 1
fi

logging "OK: process '$proc_name' is running"
exit 0
