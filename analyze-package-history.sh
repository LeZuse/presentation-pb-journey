#!/bin/bash

# Get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

HISTORY_FILE=$DIR/package-history.txt
FE_DIR=$DIR/../pb-frontend
YEAR_FROM=2015
YEAR_TO=2023

run_command() {
	echo "# $1"
	eval $1
}

: > $HISTORY_FILE

echo "Analyzing package history..."
run_command "cd $FE_DIR"

run_command "git checkout master"

for YEAR in $(seq $YEAR_FROM $YEAR_TO); do
	REV=$(git rev-list -n 1 --first-parent --before="$YEAR-01-10 23:59" master)
	run_command "git checkout $REV"
	
	echo "$YEAR:"
	echo -n "$YEAR: " >> $HISTORY_FILE
	run_command "find . -name 'package.json' -depth 1 ! -path '*/node_modules/*' | xargs jq '.dependencies | keys[]' | wc -l >> $HISTORY_FILE"
	sleep 1
done
