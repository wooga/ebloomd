-module (ebloomd_purger_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

before_test() ->
    application:start(ebloomd).

after_test() ->
    application:stop(ebloomd).


test_rotating() ->
    % When having a manager plus a filter and one element,
    {ok, Pid} = ebloomd_filter:start(100, 0.000001, 84648),
    Element = <<"some_element">>,
    ebloomd_filter:insert(Pid, Element),
    ?assert(ebloomd_filter:contains(Pid, Element)),

    ebloomd_manager:add(filter_name, Pid),

    % And then setting up flushing for it,
    ebloomd_purger:purge(filter_name, 100),

    % And waiting for a little while longer than is the timeout,
    timer:sleep(200),

    % Then the filter should have been turned over and the element gone.
    ?assert_not(ebloomd_filter:contains(Pid, Element)).
