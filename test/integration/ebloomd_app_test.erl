-module (ebloomd_app_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

after_test() ->
    application:stop(ebloomd).


test_application_startup() ->
    % When asking Erlang's `application` to start `ebloomd`,
    application:start(ebloomd),
    % Then ebloomd should be running.
    ?assert(proplists:is_defined(ebloomd, application:which_applications())).
