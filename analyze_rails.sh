#!/bin/bash

# https://chat.openai.com/share/92c20954-9398-4455-9b2b-701979492ac1

# Get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if a directory is provided
if [ -z "$1" ]; then
  echo "Please provide the directory containing the Rails source code."
  exit 1
fi

# Navigate to the directory
cd "$1" || exit 1

# Find all Ruby files and search for class inheritance
# Then count the occurrences of each parent class
find . -name '*.rb' -exec grep -E 'class [A-Za-z0-9_:]+ < [A-Za-z0-9_:]+' {} \; | \
  awk '{print $4}' | \
  sed 's/<//' | \
  sort | \
  uniq -c | \
  sort -nr \
  > $DIR/rails-parent-classes.txt

# Return to the original directory
cd - || exit 1
