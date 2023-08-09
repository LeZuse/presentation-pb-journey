#!/bin/bash

# https://chat.openai.com/share/92c20954-9398-4455-9b2b-701979492ac1

# Get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

HISTORY_FILE=$DIR/gemfile-history.txt
BE_DIR=$DIR/../pb-backend
PY_BIN=$(pyenv which python)
YEAR_FROM=2015
YEAR_TO=2023

run_command() {
	echo "# $1"
	eval "$1"
}

: > $HISTORY_FILE

echo "Analyzing package history..."
run_command "cd $BE_DIR"

run_command "git checkout master"


#TODO: check only production gems: https://pypi.org/project/gemfileparser/

SCRIPT=$(cat <<EOF
from gemfileparser import GemfileParser
parser = GemfileParser('../pb-backend/Gemfile')
dependency_dictionary = parser.parse()

print(len(dependency_dictionary['runtime']) + len(dependency_dictionary['production']))
EOF
)

# echo "$SCRIPT" | python

for YEAR in $(seq $YEAR_FROM $YEAR_TO); do
	REV=$(git rev-list -n 1 --first-parent --before="$YEAR-01-10 23:59" master)
	run_command "git checkout $REV"
	
	echo "$YEAR:"
	echo -n "$YEAR: " >> $HISTORY_FILE
	# run_command "find . -name 'Gemfile' -depth 1 | xargs grep 'gem ' | wc -l >> $HISTORY_FILE"
	run_command "echo \"$SCRIPT\" | $PY_BIN >> $HISTORY_FILE"
	sleep 1
done
