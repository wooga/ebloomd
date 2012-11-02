%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_sup).
-compile ([export_all]).


-behaviour (supervisor).
-export ([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    % Zero childs so far.
    et_sup:spec().
