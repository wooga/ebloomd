-module (ebloomd_app_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

after_test() ->
    application:stop(ebloomd).


test_application_startup() ->
    % When asking Erlang's `application` to start `ebloomd`,
    application:start(ebloomd),
    % Then ebloomd should be running.
    Applications = application:which_applications(),
    ?assert(proplists:is_defined(ebloomd, Applications)),
    % And ranch as well.
    ?assert(proplists:is_defined(ranch, Applications)).
