-module (ebloomd_node_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

after_test() ->
    application:stop(ebloomd).


test_booting_node() ->
    % When invoking the boot procedure script/control uses,
    ebloomd_node:boot(),
    % Then ebloomd should be running.
    ?assert(proplists:is_defined(ebloomd, application:which_applications())).
