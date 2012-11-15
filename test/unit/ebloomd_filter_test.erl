-module (ebloomd_filter_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

before_test() ->
    Args = [_Size = 1000, _ErrRate = 0.01, _Seed = 3684364361],
    {ok, _} = gen_server:start_link({local, filter}, ebloomd_filter, Args, []).

after_test() ->
    exit(whereis(filter), kill),
    unregister(filter).


test_insert_and_contains() ->
    % Adding a new element to the filter,
    Element = <<"some_element">>,
    ebloomd_filter:insert(filter, Element),
    % Then contains should return true,
    ?assert(ebloomd_filter:contains(filter, Element)),
    % And false for element not previously inserted.
    ?assert_not(ebloomd_filter:contains(filter, <<"some_other_element">>)).


test_rotating() ->
    % When having a filter with an element in it,
    Element = <<"some_element">>,
    ebloomd_filter:insert(filter, Element),
    ?assert(ebloomd_filter:contains(filter, Element)),

    % Then sending the rotate command,
    gen_server:call(filter, rotate),

    % Should turnover the filter.
    ?assert_not(ebloomd_filter:contains(filter, Element)).
