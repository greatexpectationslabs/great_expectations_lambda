#!/bin/bash

# install dependencies in temp dir 
# note that this does not include numpy, scipy, and pandas
PY_DIR='python/lib/python3.7/site-packages'
BRANCH='master'
BUCKET='my-temp-bucket-3856195394'

mkdir -p build/$PY_DIR
pip install --no-deps -r ge-requirements.txt -t build/$PY_DIR

cd build

git clone git@github.com:great-expectations/great_expectations.git
cd great_expectations
git checkout $BRANCH
pip install --no-deps . -t ../$PY_DIR
cd ..
rm -rf great_expectations

# zip and remove build/
zip -r ../ge_layer.zip .
cd ..
rm -r build


# PY_DIR='build/python/lib/python3.7/site-packages'
# mkdir -p $PY_DIR
# pip install --no-deps -r ge-requirements.txt -t $PY_DIR