%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_manager).
-compile ([export_all]).

-behavior (gen_server).
-export ([
    init/1, handle_call/3, handle_cast/2,
    handle_info/2, terminate/2, code_change/3]).


add(FilterName, FilterPid) ->
    gen_server:call(?MODULE, {FilterName, FilterPid}).

delete(FilterName) ->
    gen_server:call(?MODULE, {delete, FilterName}).

get(FilterName) ->
    gen_server:call(?MODULE, {get, FilterName}).



start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init(_Args) ->
    % State is the map of filter names -> filter pids.
    {ok, gb_trees:empty()}.


% Obtain the pid for the specified filter name.
handle_call({get, FilterName}, _From, Tree) ->
    FilterPid = try
        gb_trees:get(FilterName, Tree)
    catch _:_ -> undefined end,
    {reply, FilterPid, Tree};


% Insert a new filter into the list list of managed filters.
handle_call({FilterName, FilterPid}, _From, Tree) when is_pid(FilterPid) ->
    {reply, ok, gb_trees:enter(FilterName, FilterPid, Tree)};


% Remove a filter from the list.
handle_call({delete, FilterName}, _From, Tree) ->
    % Cancel all rotation timers.
    ebloomd_rotator:cancel(FilterName),
    {reply, ok, gb_trees:delete(FilterName, Tree)};


% Ignore undefined calls.
handle_call(_Message, _From, State) -> {reply, undefined, State}.
handle_cast(_Request, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> terminated.
