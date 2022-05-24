#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

GIT_ROOT=$(git rev-parse --show-toplevel)

cd "$GIT_ROOT/platform/vendor"

# read CLI args
opt_c=""
opt_d=""
opt_h=0
opt_r=""
opt_v=""

while getopts 'c:d:hr:v:' option; do
  case $option in
    c) opt_c="$OPTARG";;
    d) opt_d="$OPTARG";;
    h) opt_h=1;;
    r) opt_r="$OPTARG";;
    v) opt_v="$OPTARG";;
    *);; # unknown options ignored
  esac
done
shift "$(( OPTIND - 1 ))"

if [ $# -gt 0 ] || [ "${opt_h}" = "1" ] || [ -z "${opt_c}" ] || [ -z "${opt_d}" ] || [ -z "${opt_v}" ]; then
  echo "Usage: $0 [opts] file"
  echo " -c chart: name of chart to pull (required)"
  echo " -d dir: directory to save chart (required)"
  echo " -h: this help message"
  echo " -r repo: url for chart repository"
  echo " -v ver: version to pull (required)"
  exit 1
fi

# check if local chart matches target version, exit 0 if so
if [ "$(helm show chart "${opt_d}" 2>/dev/null | grep -e '^version: ' | cut -f2 -d' ' || true)" = "${opt_v}" ]; then
  exit 0
fi

echo -e "${C_GREEN}Vendoring ${opt_c}...${C_RESET_ALL}"

# helm pull to tmp folder
tempdir="$(mktemp -d "${opt_d}-XXX")"
trap 'rm -r "${tempdir}"; exit 1' 1 2 15
helm pull ${opt_r:+--repo "${opt_r}"} "${opt_c}" --untar --untardir "${tempdir}" --version "${opt_v}"

# delete existing folder if it exists
if [ -d "${opt_d}" ]; then
  rm -r "${opt_d}"
fi

# rename tmp folder to target
mv "${tempdir}/${opt_c}" "${opt_d}"
rm -r "${tempdir}"
