#!/bin/bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

for f in "$srcdir"/{,.}*.mustache; do
    echo "Generating $(basename "$f" .mustache)..."
    pystache meta.yml "$f" > "$(basename "$f" .mustache)"
done
