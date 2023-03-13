EXAMPLES_FILE = $(wildcard examples/*.v)
SOURCES = grapher $(EXAMPLES_FILE)
EXAMPLES = $(patsubst examples/%.v,example-%,$(EXAMPLES_FILE))

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

$(EXAMPLES): example-%: examples/%.v
	v $< -o $@

examples: $(EXAMPLES)
.PHONY: examples

clean:
	rm -f example-*
.PHONY: clean
