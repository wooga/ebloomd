.PHONY: test

all: compile test

compile:
	script/rebar compile skip_deps=true

compile_all:
	script/rebar compile

clean:
	script/rebar clean skip_deps=true

clean_all:
	script/rebar clean

test:
	script/test
