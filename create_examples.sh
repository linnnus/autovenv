#!/bin/zsh

set -e

PYTHON=/usr/bin/python3

# remove old examples
rm -rf example-*

# Create a basic example
mkdir example-basic
cd example-basic
"$PYTHON" -m virtualenv .venv
echo 'print("hello")' >hello.py
cd ..

# Create an example of nested directories with multiple virtual environments.
mkdir -p example-nested/some/sub/dir
cd example-nested/some
"$PYTHON" -m virtualenv .venv-in-some
cd sub/
"$PYTHON" -m virtualenv .venv-in-sub
cd dir/
echo 'print("hello")' >hello.py
cd ../../../..

# Create a virtual environment which has been
# moved but still has the old location hard-coded.
mkdir old-location
cd old-location
"$PYTHON" -m virtualenv .venv
cd ..
mv old-location example-outdated-location

# Create one with two virtual environments. Which one is found first?
mkdir example-multiple-venvs
cd example-multiple-venvs
"$PYTHON" -m virtualenv .venv1
"$PYTHON" -m virtualenv .venv2
cd ..

# Create one whose parent directory's name contains special characters
mkdir $'example-special \t\n!characters '
cd    $'example-special \t\n!characters '
"$PYTHON" -m virtualenv .venv
cd ..
