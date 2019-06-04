#  Coq-community Templates

[![Contributing][contributing-shield]][contributing-link]
[![Code of Conduct][conduct-shield]][conduct-link]
[![Gitter][gitter-shield]][gitter-link]

[contributing-shield]: https://img.shields.io/badge/contributions-welcome-%23f7931e.svg
[contributing-link]: https://github.com/coq-community/manifesto/blob/master/CONTRIBUTING.md

[conduct-shield]: https://img.shields.io/badge/%E2%9D%A4-code%20of%20conduct-%23f15a24.svg
[conduct-link]: https://github.com/coq-community/manifesto/blob/master/CODE_OF_CONDUCT.md

[gitter-shield]: https://img.shields.io/badge/chat-on%20gitter-%23c1272d.svg
[gitter-link]: https://gitter.im/coq-community/Lobby

This repository contains a few reusable files for Coq-community (or external)
Coq projects.

Files ending with `.mustache` have values to fill in to use (and the
`.mustache` extension should be removed).

This can (and should) be done automatically using a mustache command-line (many
`mustache` implementations are available from the [Mustache website](https://mustache.github.io).
To do so, you must write a `meta.yml` file containing the requested values.
For instance, the [example files](https://github.com/coq-community/manifesto) were generated in the
following way:

``` shell
for dir in examples/*; do
  for f in default.nix.mustache README.md.mustache .travis.yml.mustache; do
    mustache $dir/meta.yml $f > $dir/${f%.mustache} && \
    echo "$dir/${f%.mustache}"
  done
  mustache $dir/meta.yml coq.opam.mustache > $dir/coq-${dir#examples/}.opam && \
  echo "$dir/coq-${dir#examples/}.opam"
done
```
You may find documentation, advice and guidelines on how to maintain a project
in the [wiki](https://github.com/coq-community/manifesto/wiki).
