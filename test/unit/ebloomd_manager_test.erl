-module (ebloomd_manager_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

before_test() ->
    ebloomd_manager:start_link().

after_test() ->
    exit(whereis(ebloomd_manager), kill),
    unregister(ebloomd_manager).


test_inserting() ->
    % Adding a new element to the manager,
    ebloomd_manager:add(filter_name, self()),
    % Should return that very element again.
    ?assert_equal(self(), ebloomd_manager:get(filter_name)),

    % And when inserting a different element for the same key,
    Pid = spawn(fun() -> ok end),
    ebloomd_manager:add(filter_name, Pid),
    ?assert_equal(Pid, ebloomd_manager:get(filter_name)).


test_getting() ->
    % Getting an element not previously entered, should return undefined.
    ?assert_equal(undefined, ebloomd_manager:get(undefined)).


test_removing() ->
    % When inserting a new element,
    ebloomd_manager:add(filter_name, self()),
    % And then removing it,
    ebloomd_manager:delete(filter_name),
    % Should yield undefined when asking for the element again.
    ?assert_equal(undefined, ebloomd_manager:get(filter_name)).
