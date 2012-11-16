%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_app).
-compile ([export_all]).


-behaviour (application).
-export ([start/2, stop/1]).

% Callback starting the backend.
start(_StartType, _StartArgs) ->
    application:start(ranch),
    ebloomd_sup:start_link().

% Just `ok`.
stop(_State) -> ok.
