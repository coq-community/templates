#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

get_yaml() {
    # Arg 1: the meta.yml path
    # STDIN: the mustache code
    local meta="$1" temp
    temp=$(mktemp --tmpdir --suffix .yml template-XXX)
    cat > "$temp"
    mustache "$meta" "$temp"
    rm -f -- "$temp"
}

for f in "$srcdir"/{,.}*.mustache; do
    target=$(basename "$f" .mustache)
    case "$target" in
        coq.opam)
            mustache='{{ opam_name }}'
            opam_name=$(get_yaml meta.yml <<<"$mustache")
	    if [ -n "$opam_name" ]; then
		target=${target/coq/$opam_name}
	    else
		mustache='{{ shortname }}'
		shortname=$(get_yaml meta.yml <<<"$mustache")
		if [ -n "$shortname" ]; then
		    target=${target/coq/coq-$shortname}
	        else
		    continue
		fi
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
            mustache='{{ action }}'
            bool=$(get_yaml meta.yml <<<"$mustache")
            if [ -n "$bool" ] && [ "$bool" != false ]; then
                mkdir -p -v .github/workflows && target=".github/workflows/$target"
            else
                continue
            fi
            ;;
        .travis.yml)
            mustache='{{ travis }}'
            bool=$(get_yaml meta.yml <<<"$mustache")
            if [ -n "$bool" ] && [ "$bool" != false ]; then
                : noop
            else
                continue
            fi
            ;;
        default.nix)
            mustache='{{ tested_coq_nix_versions }}'
            bool=$(get_yaml meta.yml <<<"$mustache")
            if [ -n "$bool" ] && [ "$bool" != false ]; then
                : noop
            else
                continue
            fi
            ;;
    esac
    echo "Generating $target..."
    mustache meta.yml "$f" > "$target"
done
