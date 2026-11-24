#!/usr/bin/env sh
set -eu

if [ "$#" -lt 2 ]; then
  echo "Usage: sq-cli.sh <project> <record|pause|resume|stop|status> [settings]" >&2
  exit 2
fi

project=$1
shift

exec WCCOActrl -proj "$project" -log +stderr splash/cli.ctl "$@"