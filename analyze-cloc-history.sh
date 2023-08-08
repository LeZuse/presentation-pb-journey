#!/bin/bash

# Get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

HISTORY_FILE=$DIR/be-cloc-history
FE_DIR=$DIR/../pb-backend
YEAR_FROM=2015
YEAR_TO=2023

run_command() {
	echo "# $1"
	eval $1
}

echo "Analyzing package history..."
run_command "cd $FE_DIR"

run_command "git checkout master"

for YEAR in $(seq $YEAR_FROM $YEAR_TO); do
	REV=$(git rev-list -n 1 --first-parent --before="$YEAR-01-10 23:59" master)
	run_command "git checkout $REV"
	
	: > $HISTORY_FILE-$YEAR.txt
	run_command "cloc . --exclude-dir=node_modules,__generated__,dist --out=$HISTORY_FILE-$YEAR.txt"
	sleep 1
done
