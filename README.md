## `embloomd`
Have multiple named Bloom Filters side-by-side. Purge filters in intervals if desired.


## Installation
Add `ebloomd` as a [rebar](https://github.com/basho/rebar) dependency and make sure `ebloomd` is started with your application.

```erlang
% rebar.config
{deps, [
    {ebloomd, "",
        {git, "git://github.com/wooga/etest.git",
        {branch, "master"}}}
]}.
```

Next run `make` to fetch all dependencies, compile and run the tests.
