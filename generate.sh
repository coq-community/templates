#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

ask1() { local yn; echo -n "$* [Y/n] "; read -r -n 1 yn; [[ "$yn" =~ [Yy] ]] && echo && return 0; [ -z "$yn" ] && return 0; echo; return 1; }

get_yaml() {
    # Arg 1: the meta.yml path
    # STDIN: the mustache code
    local meta="$1" temp
    temp=$(mktemp --tmpdir --suffix .yml template-XXX)
    cat > "$temp"
    mustache "$meta" "$temp"
    rm -f "$temp"
}

for f in "$srcdir"/{,.}*.mustache; do
    target=$(basename "$f" .mustache)
    case "$target" in
        coq.opam)
            mustache='{{ shortname }}'
            shortname=$(get_yaml meta.yml <<<"$mustache")
            if [ -n "$shortname" ]; then
                target=${target/coq/coq-$shortname}
            else
                continue
            fi
            ;;
        extracted.opam)
            mustache='{{# extracted }}{{ extracted_shortname }}{{/ extracted }}'
            extracted_shortname=$(get_yaml meta.yml <<<"$mustache")
            if [ -n "$extracted_shortname" ]; then
                target=${target/extracted/$extracted_shortname}
            else
                continue
            fi
            ;;
        coq-action.yml)
            if ask1 "Do you wish to generate the file .github/workflows/coq-action.yml?"; then
                mkdir -p -v .github/workflows && target=".github/workflows/$target"
            else
                continue
            fi
            ;;
    esac
    echo "Generating $target..."
    mustache meta.yml "$f" > "$target"
done
