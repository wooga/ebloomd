-module (ebloomd_sup_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").


test_main_sup_spec() ->
    % When requesting the supervisor spec, expect it to be empty.
    ExpSpec = et_sup:spec ([
        et_sup:child(ebloomd_manager, worker),
        et_sup:child(ebloomd_rotator, worker)
    ]),
    ?assert_equal(ExpSpec, ebloomd_sup:init([])).


test_manager() ->
    % When starting the supervisor,
    {ok, Pid} = supervisor:start_link(ebloomd_sup, []),
    % ebloomd_manager should start as well,
    ?assert(is_process_alive(whereis(ebloomd_manager))),
    exit(Pid, kill).


test_rotator() ->
    % When starting the supervisor,
    {ok, Pid} = supervisor:start_link(ebloomd_sup, []),
    % ebloomd_manager should start as well,
    ?assert(is_process_alive(whereis(ebloomd_rotator))),
    exit(Pid, kill).
