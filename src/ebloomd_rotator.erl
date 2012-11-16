%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_rotator).
-compile ([export_all]).

-behavior (gen_server).
-export ([
    init/1, handle_call/3, handle_cast/2,
    handle_info/2, terminate/2, code_change/3]).


rotate(FilterName, Interval) ->
    gen_server:cast(?MODULE, {rotate, FilterName, Interval}).

cancel(FilterName) ->
    gen_server:cast(?MODULE, {cancel, FilterName}).



start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init(_) ->
    % State: FilterName -> TimerRef.
    {ok, gb_trees:empty()}.


% Check for element membership with the filter.
handle_cast({rotate, FilterName, Interval}, Tree) ->
    % Cancel old timer,
    {_, CleanTree} = handle_cast({cancel, FilterName}, Tree),
    % Set up new timer.
    {ok, TRef} =
        timer:apply_interval(Interval,?MODULE, send_rotate, [FilterName]),
    {noreply, gb_trees:insert(FilterName, TRef, CleanTree)};


% Cancel the rotation timer.
handle_cast({cancel, FilterName}, Tree) ->
    NewTree = try
        timer:cancel(gb_trees:get(FilterName, Tree)),
        gb_trees:delete(FilterName, Tree)
    catch _:_ -> Tree end,
    {noreply, NewTree};


% Ignore undefined calls.
handle_cast(_Request, State) -> {noreply, State}.
handle_call(_Message, _From, State) -> {reply, undefined, State}.
handle_info(_Info, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> terminated.


% Send the rotate command to the filter.
send_rotate(FilterName) ->
    FilterPid = ebloomd_manager:get(FilterName),
    gen_server:call(FilterPid, rotate).
