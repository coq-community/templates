# Templates for Coq projects in coq-community and elsewhere

[![Contributing][contributing-shield]][contributing-link]
[![Code of Conduct][conduct-shield]][conduct-link]
[![Zulip][zulip-shield]][zulip-link]

[contributing-shield]: https://img.shields.io/badge/contributions-welcome-%23f7931e.svg
[contributing-link]: https://github.com/coq-community/manifesto/blob/master/CONTRIBUTING.md

[conduct-shield]: https://img.shields.io/badge/%E2%9D%A4-code%20of%20conduct-%23f15a24.svg
[conduct-link]: https://github.com/coq-community/manifesto/blob/master/CODE_OF_CONDUCT.md

[zulip-shield]: https://img.shields.io/badge/chat-on%20zulip-%23c1272d.svg
[zulip-link]: https://coq.zulipchat.com/#narrow/stream/237663-coq-community-devs.20.26.20users

This repository contains template files for use in generating configuration files
and other boilerplate for coq-community (or external) Coq projects.
All content in the repository is licensed under the [Unlicense](LICENSE).

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
Note that the `mustache` available via opam does *not* work!

### The `meta.yml` file

To enable generating files (e.g, `.opam` files and CI setup) using one such
mustache tool, one needs to provide a `meta.yml` file containing the required
values. Depending on your project and the desired setup, the `meta.yml` files of
one of the following projects may serve as a starting point:

- [Huffman](https://github.com/coq-community/huffman) (pure library, no dependencies, coq-community):
  [meta.yml](https://github.com/coq-community/huffman/blob/master/meta.yml)
- [AAC Tactics](https://github.com/coq-community/aac-tactics) (plugin, one-branch per Coq version):
  [meta.yml](https://github.com/coq-community/aac-tactics/blob/master/meta.yml)
- [reglang](https://github.com/coq-community/reglang) (pure library, mathcomp, custom docker images):
  [meta.yml](https://github.com/coq-community/reglang/blob/master/meta.yml)
- [StructTact](https://github.com/uwplse/StructTact) (pure library, no dependencies, no coq-community):
  [meta.yml](https://github.com/uwplse/StructTact/blob/master/meta.yml)

A description of all available keys and the template files they are used in can
be found in [`ref.yml`](ref.yml).

### Generating configuration files using the `generate.sh` script

Once `<your-project>/meta.yml` is written, the standard files can be generated
by calling the `generate.sh` script in the following manner:

```shell
cd <your-project>
TMP=$(mktemp -d); git clone https://github.com/coq-community/templates.git $TMP
$TMP/generate.sh # nix users can do instead: nix-shell -p mustache-go --run $TMP/generate.sh
git add <the_generated_files>
```
Regarding continuous integration, the `generate.sh` script will create:
* a [Travis CI](https://docs.travis-ci.com/) configuration
    [(based on opam + Nix)](./.travis.yml.mustache),
* or a [GitHub Action](https://help.github.com/en/actions) workflow
    (based on [opam](./docker-action.yml.mustache) or [Nix](./nix-action.yml.mustache)),
* or a [CircleCI](https://circleci.com/) configuration
    [(based on opam)](./config.yml.mustache),

depending on whether `meta.yml` contains `travis: true` or `action: true`
or `circleci: true`.

For `coq-community` projects, using `travis: true` is currently
disabled due to a very limited build-time allowance from Travis. Using
GitHub actions is a reasonable choice.

If you only want to (re)generate certain files, you can specify them as arguments to the shell script:
```shell
$TMP/generate.sh README.md .github/workflows/docker-action.yml
```

All files generated from the templates should be kept under version
control as continuous integration needs its config file as well as the
`.opam` file to be present in the repository and GitHub needs the
`README.md` file order to display it.

### Manual generation of files using the templates.

As an alternative to using `generate.sh`, the configuration files can
also be generated by calling `mustache` directly. For instance,
asuming the templates are available in a sibling directory, a standard
`README.md` can be generated as follows: 

```shell
mustache meta.yml ../templates/README.md.mustache > README.md
```

### Further information

You can find documentation, advice, and guidelines on how to maintain a Coq project
in the [wiki](https://github.com/coq-community/manifesto/wiki).
