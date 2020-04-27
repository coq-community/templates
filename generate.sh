#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

function ask1() { local yn; echo -n "$* [Y/n] "; read -r -n 1 yn; [[ "$yn" =~ [Yy] ]] && echo && return 0; [ -z "$yn" ] && return 0; echo; return 1; }

for f in "$srcdir"/{,.}*.mustache; do
    target=$(basename "$f" .mustache)
    case "$target" in
        coq.opam)
            shortname=$(grep -e "^shortname:" meta.yml | sed -e 's/^shortname:\s\+//')
            if [ -n "$shortname" ]; then
                target=${target/coq/coq-$shortname}
            else
                continue
            fi
            ;;
        extracted.opam)
            extracted_shortname=$(grep -e "^\s\+extracted_shortname:" meta.yml | sed -e 's/^\s\+extracted_shortname:\s\+//')
            if [ -n "$extracted_shortname" ]; then
                target=${target/extracted/$extracted_shortname}
            else
                continue
            fi
            ;;
        coq-action.yml)
            if ask1 "Do you wish to generate the file .github/workflows/coq-action.yml?"; then
                mkdir -p .github/workflows; target=".github/workflows/$target"
            else
                continue
            fi
            ;;
    esac
    echo "Generating $target..."
    mustache meta.yml "$f" > "$target"
done
