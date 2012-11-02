-module (eblooms_sup_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").

test_main_sup_spec() ->
    % When requesting the supervisor spec, expect it to be empty.
    ?assert_equal(et_sup:spec([]), ebloomd_sup:init([])).
