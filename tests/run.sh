#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}")
LIB=$DIR/..
FAIL=0

testcase() {
    NAME="$1"
    IN="$DIR"/$NAME.in.json
    OUT="$DIR"/$NAME.out.json
    JQ="$DIR"/$NAME.jq

    jq -e -n '[inputs]|.[0]==.[1]' <(jq -L"$LIB" -f "$JQ" "$IN") "$OUT" >/dev/null

    if [ $? -eq 0 ]; then
      echo -e "\e[32m✔ $NAME\e[0m"
    else
      echo -e "\e[31m✘ $NAME\e[0m"
      let FAIL++
      diff -U0 -d <(jq -S -L"$LIB" -f "$JQ" "$IN") <(jq -S . "$OUT") \
        | grep -e '^[+-] ' | sed 's/^/  /'
    fi
}

for JQ in "$DIR"/*.jq; do
    testcase $(basename "$JQ" .jq)
done

if [ $FAIL -ne 0 ]; then
  echo
  echo -e "\e[31m$FAIL tests failed!\e[0m"
  exit 1
fi
