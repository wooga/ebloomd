.PHONY: test

all: clean_all get_deps compile_all test

get_deps:
	script/rebar get-deps

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
