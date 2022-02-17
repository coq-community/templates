# Repository configuration tools for Coq projects

[![Zulip][zulip-shield]][zulip-link]

[zulip-shield]: https://img.shields.io/badge/chat-on%20zulip-%23c1272d.svg
[zulip-link]: https://coq.zulipchat.com/#narrow/stream/237663-coq-community-devs.20.26.20users

Development of OCaml-based tools for supporting advanced version control repository configuration in projects using the Coq proof assistant.

## Goals

- Define YAML-like file format for describing Coq projects, including projects that have complex packaging and dependencies.
- Develop OCaml-based command line tool to use files in the specified format for generating repository configuration files and documentation (`README.md`, `coq-project.opam`, etc.)
- Apply the format and tools on both simple and advanced open source Coq projects

## Current Tasks

- Write project proposal in LaTeX of 1-2 pages
- Refine the current entity-relationship model
- Finalize list of initial projects to support

## Example Coq projects to support

- [Huffman](https://github.com/coq-community/huffman) (single-package Coq library project with unused extraction)
- [Stalmarck](https://github.com/coq-community/stalmarck) (multi-package Coq library, plugin, and OCaml tool)
- [MathComp](https://github.com/math-comp/math-comp) (multi-package Coq library)

## Entity-relationship diagram

<img src="er-diagram.svg" width="400" alt="ER diagram">

