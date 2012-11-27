-module (ebloomd_redis_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

before_test() ->
    application:start(ebloomd).

after_test() ->
    application:stop(ranch),
    application:stop(ebloomd).


% % Not implemented atm.
% test_select() ->
%     % When calling select for a database,
%     % which is then interpreted as a filter name,
%     {Host, Port, Database} = {"127.0.0.1", 6380, 14},
%     {ok, C} = eredis:start_link(Host, Port, Database),
%     % Then the filter with that name should be available.
%     ?assert_match({ok, _Pid}, ebloomd_manager:get(14)).


test_set_and_get() ->
    Args = [_Size = 1000, _ErrRate = 0.01, _Seed = 3684364361],
    {ok, FPid} = gen_server:start({local, filter}, ebloomd_filter, Args, []),
    ebloomd_manager:add(default, FPid),

    % GET and SET should work just as expected.
    {Host, Port, Database} = {"127.0.0.1", 6380, 14},
    {ok, C} = eredis:start_link(Host, Port, Database),

    ?assert_equal({ok, <<"OK">>}, eredis:q(C, ["SET", "foo", "bar"])),
    ?assert_equal({ok, <<"1">>}, eredis:q(C, ["GET", "foo"])),
    ?assert_equal({ok, <<"0">>}, eredis:q(C, ["GET", "bar"])).
