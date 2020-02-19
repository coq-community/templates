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

This repository contains template files for use in generating configuration files
and other boilerplate for coq-community (or external) Coq projects.

Files ending in `.mustache` have values to fill in (and the `.mustache`
extension should be removed from the resulting files). Filling in values can (and should)
be done automatically using a mustache command-line tool. There are many mustache
implementations available from the [Mustache website](https://mustache.github.io).
Note that these implementations can differ w.r.t. the supported input
format (for your project metadata). We suggest you rely on a
YAML-compatible mustache implementation such as `ruby-mustache`
(available for instance as an
[Ubuntu](https://packages.ubuntu.com/ruby-mustache) or
[Debian](https://packages.debian.org/ruby-mustache) package).

To enable generating files using one such mustache tool, you should
thus write a `meta.yml` file containing the required values. For
example, assuming the templates are available in a sibling directory,
configuration and boilerplate files in the
[AAC Tactics](https://github.com/coq-community/aac-tactics)
project are generated as follows:
```shell
mustache meta.yml ../templates/default.nix.mustache > default.nix
mustache meta.yml ../templates/README.md.mustache > README.md
mustache meta.yml ../templates/.travis.yml.mustache > .travis.yml
mustache meta.yml ../templates/coq.opam.mustache > coq-aac-tactics.opam
```
Other projects using the templates in a similar way include
[Chapar](https://github.com/coq-community/chapar) and
[Lemma Overloading](https://github.com/coq-community/lemma-overloading).

You can generate the standard files from the templates, provided
you have already written `meta.yml`, in the following way:

1. Clone https://github.com/coq-community/templates.git as subdirectory or submodule.
2. Include [`Makefile.meta`](Makefile.meta) in your `Makefile`.
3. (Optional) Add rules for extracted OPAM file.
4. Specify build targets.

See [example](example) for more details.

Keeping generated files under version control is not ideal, but `README.md` has to exist,
and generally this is a common practice when using build systems such as Autotools.
To get a `mustache` tool in, e.g., NixOS, you can run `nix-env -i mustache-go`.

You can find documentation, advice, and guidelines on how to maintain a Coq project
in the [wiki](https://github.com/coq-community/manifesto/wiki).
