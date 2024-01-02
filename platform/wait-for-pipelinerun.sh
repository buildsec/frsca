#!/usr/bin/env bash
set -euo pipefail

# ANSI colors
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_RESET_ALL='\033[0m'

function _log() {
  echo -e "$1$2${C_RESET_ALL}"
}

function info() {
  _log "${C_GREEN}" "$1"
}

function progress() {
  _log "${C_CYAN}" "$1"
}

function warn() {
  _log "${C_YELLOW}" "$1"
}

function error() {
  _log "${C_RED}" "$1"
}

# read CLI args
opt_m=""
opt_n=""
opt_h=0

while getopts 'm:n:h' option; do
  case $option in
    m) opt_m="$OPTARG";;
    n) opt_n="$OPTARG";;
    h) opt_h=1;;
    *);; # ignore
  esac
done
shift "$(( OPTIND - 1 ))"
if [ $# -gt 0 ] || [ -z "${opt_m}" ] || [ -z "${opt_n}" ] || [ "${opt_h}" = 1 ]; then
  warn "Usage: $0 [opts]"
  warn " -h: this help message"
  warn " -m cmd: make command to create a PipelineRun (required)"
  warn " -n name: generated name prefix of PipelineRun (required)"
  exit 1
fi

info "Waiting for PipelineRun creation: ${opt_m} ${opt_n}"

function tkn_pr() {
  tkn pr ls -o jsonpath='{.items[?(@.metadata.generateName == "'"$1"'")].metadata.name}'
}

WAIT_CNT=0
RETRIES=0
while [ -z "$(tkn_pr "${opt_n}")" ]; do
  if [ "$WAIT_CNT" -eq 0 ]; then
    if [ "$RETRIES" -lt 2 ]; then
      RETRIES=$((RETRIES + 1))
      make "${opt_m}"
    else
      error "Failed to create PipelineRun: ${opt_m} ${opt_n}"
      exit 1
    fi
  fi
  if [ "$WAIT_CNT" -gt 15 ]; then
    warn "Retrying ${opt_n}"
    WAIT_CNT=0
  else
    WAIT_CNT=$((WAIT_CNT + 1))
    progress "Waiting for PipelineRun ${opt_n}"
    sleep 1
  fi
done

info "PipelineRun created: ${opt_m} ${opt_n}"
