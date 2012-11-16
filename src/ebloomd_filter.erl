%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_filter).
-compile ([export_all]).

-behavior (gen_server).
-export ([
    init/1, handle_call/3, handle_cast/2,
    handle_info/2, terminate/2, code_change/3]).


insert(FilterPid, Element) ->
    gen_server:cast(FilterPid, {insert, Element}).

contains(FilterPid, Element) ->
    gen_server:call(FilterPid, {contains, Element}).



start_link(Size, ErrRate, Seed) ->
    gen_server:start_link(?MODULE, [Size, ErrRate, Seed], []).


init(Settings = [Size, ErrRate, Seed]) ->
    % State is the reference to the mutable filter.
    {ok, Ref} = ebloom:new(Size, ErrRate, Seed),
    {ok, {Ref, Settings}}.



% Rotate by replacing the filter altogether.
handle_call(rotate, _From, {_Ref, Settings}) ->
    {ok, NewS} = init(Settings),
    {reply, done, NewS};


% Check for element membership with the filter.
handle_call({contains, Element}, _From, S = {Ref, _}) when is_binary(Element) ->
    {reply, ebloom:contains(Ref, Element), S};

handle_call(_Message, _From, State) ->
    {reply, undefined, State}.


% Insert a new element into the bloom filter.
handle_cast({insert, Element}, S = {Ref, _}) when is_binary(Element) ->
    ebloom:insert(Ref, Element),
    {noreply, S};


% Ignore undefined calls.
handle_cast(_Request, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> terminated.
