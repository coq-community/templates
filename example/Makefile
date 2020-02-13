TEMPLATES ?= templates

TARGETS= \
	.travis.yml \
	README.md \
	coq-chapar.opam \
	coq-chapar-stores.opam \
	default.nix \
	index.html

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

coq-chapar-stores.opam: meta.yml $(TEMPLATES)/extracted.opam.mustache
	@echo "Generating $@..."
	mustache $^ > $@

include $(TEMPLATES)/Makefile.meta
