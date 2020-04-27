#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

function ask1() { local yn; echo -n "$* [Y/n] "; read -r -n 1 yn; [[ "$yn" =~ [Yy] ]] && echo && return 0; [ -z "$yn" ] && return 0; echo; return 1; }

for f in "$srcdir"/{,.}*.mustache; do
    target=$(basename "$f" .mustache)
    case "$target" in
        coq.opam)
            shortname=$(grep -e "^shortname:" meta.yml | sed -e 's/^shortname:\s\+//')
            [ -n "$shortname" ] && target=${target/coq/coq-$shortname}
            ;;
        extracted.opam)
            extracted_shortname=$(grep -e "^\s\+extracted_shortname:" meta.yml | sed -e 's/^\s\+extracted_shortname:\s\+//')
            [ -n "$extracted_shortname" ] && target=${target/extracted/$extracted_shortname}
            ;;
        coq-action.yml)
            ask1 "Do you want to create a .github/workflows subfolder for coq-action.yml?" &&
                { mkdir -p .github/workflows; target=".github/workflows/$target"; }
            ;;
    esac
    echo "Generating $target..."
    mustache meta.yml "$f" > "$target"
done
