#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

for f in "$srcdir"/{,.}*.mustache; do
    target=$(basename "$f" .mustache)
    case "$target" in
        *.opam)
            shortname=$(grep -e "shortname:" meta.yml | sed -e "s/^shortname: //")
            target=${target/coq/coq-$shortname}
            ;;
    esac
    echo "Generating $target..."
    mustache meta.yml "$f" > "$target"
done
