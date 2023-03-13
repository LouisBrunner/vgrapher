EXAMPLES := exp
SOURCES = grapher

REXAMPLES = $(addprefix example-,$(EXAMPLES))

all: lint test examples
.PHONY: all

format:
	v fmt -w $(SOURCES)
.PHONY: format

lint:
	v fmt -verify -diff $(SOURCES)
	v vet $(SOURCES)
.PHONY: lint

test:
	v test $(SOURCES)
.PHONY: test

$(REXAMPLES): example-%: examples/%.v
	v $< -o $@

examples: $(REXAMPLES)
.PHONY: examples

clean:
	rm -f example-*
.PHONY: clean
