%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_sup).
-compile ([export_all]).

-behaviour (supervisor).
-export ([start_link/0, init/1]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init(_Args) ->
    % Start the filter manager, the purger and the redis interface.
    et_sup:spec ([
        et_sup:child(ebloomd_manager, worker),
        et_sup:child(ebloomd_purger, worker)
    ]).
