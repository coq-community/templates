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
extension should be removed from the resulting files). Filling in values
is done automatically using a mustache command-line tool. There are many mustache
implementations available from the [Mustache website](https://mustache.github.io).
Note that these implementations can differ w.r.t. the supported input
format (for your project metadata). We suggest you rely on a
YAML-compatible mustache implementation such as `ruby-mustache`
(available for instance as an
[Ubuntu](https://packages.ubuntu.com/ruby-mustache) or
[Debian](https://packages.debian.org/ruby-mustache) package)
or `mustache-go` (available as a
[Nix](https://nixos.org/nixos/packages.html?attr=mustache-go&channel=nixpkgs-unstable) package).

To enable generating files using one such mustache tool, you should
thus write a `meta.yml` file containing the required values. For
example, assuming the templates are available in a sibling directory,
configuration and boilerplate files in the
[AAC Tactics](https://github.com/coq-community/aac-tactics)
project are generated as follows:
```shell
mustache meta.yml ../templates/README.md.mustache > README.md
mustache meta.yml ../templates/coq.opam.mustache > coq-aac-tactics.opam
mustache meta.yml ../templates/default.nix.mustache > default.nix
mustache meta.yml ../templates/.travis.yml.mustache > .travis.yml
```
Other projects using the templates in a similar way include
[Chapar](https://github.com/coq-community/chapar) and
[Lemma Overloading](https://github.com/coq-community/lemma-overloading).

All the keys used by templates files are specified in [`ref.yml`](ref.yml).

You can generate the standard files from the templates, provided
you have already written `meta.yml`, in the following way:
```shell
cd <your_coq_project> && cd ..
git clone https://github.com/coq-community/templates.git
cd -
../templates/generate.sh
git add <the_generated_files>
```
Regarding continuous integration, the `generate.sh` script will create:
* a [Travis CI](https://docs.travis-ci.com/) configuration
    [(based on opam + Nix)](./.travis.yml.mustache),
* or a [GitHub Action](https://help.github.com/en/actions) workflow
    [(based on opam)](./coq-action.yml.mustache),
* or a [CircleCI](https://circleci.com/) configuration
    [(based on opam)](./config.yml.mustache),

depending on whether `meta.yml` contains `travis: true` or `action: true`
or `circleci: true`.

If you only want to generate certain files, please specify them as shell script arguments:
```shell
../templates/generate.sh README.md coq-aac-tactics.opam
```

Keeping generated files under version control is not ideal, but `README.md` has to exist,
and generally this is a common practice when using build systems such as Autotools.
To get a `mustache` tool in, e.g., NixOS, you can run `nix-env -i mustache-go`.

You can find documentation, advice, and guidelines on how to maintain a Coq project
in the [wiki](https://github.com/coq-community/manifesto/wiki).
