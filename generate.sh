#!/bin/sh

for f in `dirname $0`/{,.}*.mustache
do
    echo "Generating `basename $f .mustache`..."
    mustache meta.yml $f > `basename $f .mustache`
done
