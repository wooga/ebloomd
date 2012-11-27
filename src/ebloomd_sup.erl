%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_sup).
-compile ([export_all]).

-behaviour (supervisor).
-export ([start_link/0, init/1]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init(_Args) ->
    % Ranch/redis interface listener options.
    RanchOpts = [
        _Ref = ebloomd_redis,
        _NbAcceptors = 128,
        _Transport = ranch_tcp,
        _TransOpts = [{port, 6380}, {max_connections, infinity}],
        _Protocol = ebloomd_redis,
        _ProtoOpts = []
    ],

    % Start the filter manager, the purger and the redis interface.
    et_sup:spec ([
        et_sup:child(ebloomd_manager, worker),
        et_sup:child(ebloomd_purger, worker),
        et_sup:child(ebloomd_redis, {ranch, start_listener, RanchOpts})
    ]).
