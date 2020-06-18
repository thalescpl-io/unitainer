.PHONY: preso gen

gen:
		@prototool generate

preso:
		@present -base preso index.slide

build:
		@go build github.com/thalescpl-io/unitainer/examples/hello_cloud