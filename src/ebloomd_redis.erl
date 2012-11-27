%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_redis).
-compile ([export_all]).
-include_lib ("et/include/et_types.hrl").

-behaviour (ranch_protocol).
-export ([start_link/4]).


% Callback invoked by ranch to setup the connection handler.
start_link(ListenerPid, Socket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, Opts]),
    {ok, Pid}.


init(ListenerPid, Socket, Transport, _Opts = []) ->
    ok = ranch:accept_ack(ListenerPid),
    loop(Socket, Transport, _Db = default).


loop(Socket, Transport, Db) ->
    % 500ms timeout since most likely used from within the same network.
    case Transport:recv(Socket, _Length = 0, _Timeout = 500) of
        {ok, Data} ->
            {Reply, NewDb} = handle(Data, Db),
            Transport:send(Socket, Reply),
            loop(Socket, Transport, NewDb);

        _ -> Transport:close(Socket)
    end.


% % Not supporting selects at the moment.
% handle(<<"SELECT", Rest/binary>>, Db) ->
%     {ok, [NewDB], _} = io_lib:fread("~d", ?b2l(Rest)),
%     % TODO - Setup the filter and register it with the manager.
%     {<<"+OK\r\n">>, NewDB};


% Handle set requests by inserting the key into the filter and ignoring the
% value altogether.
handle(<<"*3\r\n$3\r\nSET\r\n", Rest/binary>>, Db) ->
    case io_lib:fread("$~d\r\n~s\r\n$~d\r\n~s\r\n", ?b2l(Rest)) of
        {ok, [_, KeyStr, _, _], _} ->
            ebloomd_filter:insert(ebloomd_manager:get(Db), KeyStr);

        _ -> continue
    end,
    {<<"+OK\r\n">>, Db};


% Handle get requests by looking up the presented key in the filter and
% returning either 1 in case present or 0 as the 'original' value.
handle(<<"*2\r\n$3\r\nGET\r\n", Rest/binary>>, Db) ->
    Reply = case io_lib:fread("$~d\r\n~s\r\n", ?b2l(Rest)) of
        {ok, [_, KeyStr], _} ->
            case ebloomd_filter:contains(ebloomd_manager:get(Db), KeyStr) of
                true -> <<"+1\r\n">>;
                _ -> <<"+0\r\n">>
            end;

        _ -> <<"+0\r\n">>
    end,
    {Reply, Db};


handle(Data, Db) ->
    {<<"+OK\r\n">>, Db}.
