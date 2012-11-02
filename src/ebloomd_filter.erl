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


init([Size, ErrRate, Seed]) ->
    % State is the reference to the mutable filter.
    {ok, Ref} = ebloom:new(Size, ErrRate, Seed),
    {ok, Ref}.


% Check for element membership with the filter.
handle_call({contains, Element}, _From, Ref) when is_binary(Element) ->
    {reply, ebloom:contains(Ref, Element), Ref};

handle_call(_Message, _From, State) ->
    {reply, undefined, State}.


% Insert a new element into the bloom filter.
handle_cast({insert, Element}, Ref) when is_binary(Element) ->
    ebloom:insert(Ref, Element),
    {noreply, Ref};

handle_cast(_Request, State) ->
    {noreply, State}.


% Ignore undefined calls.
handle_info(_Info, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> terminated.
