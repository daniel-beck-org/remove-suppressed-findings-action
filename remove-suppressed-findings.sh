#!/usr/bin/env bash

which jq > /dev/null || { echo "$0 requires 'jq' to be on the PATH" >&2 ; exit 1 ; }
[[ $# -eq 1 ]] || { echo "$0 expects 1 argument, but got $#" >&2 ; exit 1 ; }

function process_sarif {
  FILE="$1"
    echo "Processing $FILE ..." >&2
    jq 'del(.runs[].results[] | select( .suppressions | length != 0 ))' "$FILE" > "$FILE.filtered" || { echo "Failed to process '$FILE' with 'jq'" >&2 ; return ; }
    mv -v "$FILE.filtered" "$FILE" || { echo "Failed to replace unfiltered '$FILE' with filtered output" >&2 ; }
}

if [[ -d "$1" ]] ; then
  # Directory specified, convert all SARIF files in there
  for FILE in "$1"/*.sarif ; do
    process_sarif "$FILE"
  done
elif [[ -f "$1" ]] ; then
  process_sarif "$1"
else
  echo "$1 is neither a file nor directory" >&2
  exit 1
fi
