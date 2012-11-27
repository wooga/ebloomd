-module (ebloomd_sup_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").


before_test() ->
    application:start(ranch).

after_test() ->
    application:stop(ranch).


test_main_sup_spec() ->
    RanchOpts = [
        _Ref = ebloomd_redis,
        _NbAcceptors = 128,
        _Transport = ranch_tcp,
        _TransOpts = [{port, 6380}, {max_connections, infinity}],
        _Protocol = ebloomd_redis,
        _ProtoOpts = []
    ],
    % When requesting the supervisor spec, expect it to contain the manager,
    % the purger and the redis interface listener.
    ExpSpec = et_sup:spec ([
        et_sup:child(ebloomd_manager, worker),
        et_sup:child(ebloomd_purger, worker),
        et_sup:child(ebloomd_redis, {ranch, start_listener, RanchOpts})
    ]),
    ?assert_equal(ExpSpec, ebloomd_sup:init([])).


test_manager() ->
    % When starting the supervisor,
    {ok, Pid} = supervisor:start_link(ebloomd_sup, []),
    % ebloomd_manager should start as well,
    ?assert(is_process_alive(whereis(ebloomd_manager))),
    exit(Pid, kill).


test_purger() ->
    % When starting the supervisor,
    {ok, Pid} = supervisor:start_link(ebloomd_sup, []),
    % ebloomd_manager should start as well,
    ?assert(is_process_alive(whereis(ebloomd_purger))),
    exit(Pid, kill).
