%% @license The FreeBSD License
%% @copyright 2012 Wooga GmbH

-module (ebloomd_node).
-compile ([export_all]).
-include_lib ("et/include/et_types.hrl").


boot() ->
    application:start(ebloomd).


reload([Node, AppRoot]) ->
    {Status, Message} = rpc:call (
        Node, ?MODULE, local_reload,
        [code:get_path(), ?a2l(AppRoot)]
    ),
    io:format("~s~n", [Message]),
    erlang:halt(Status).


% Perform a hot code reload on the local node.
local_reload(_AppRoot, LoadPaths) ->
    % Modules belonging to the application,
    AppFile = code:where_is_file("ebloomd.app"),
    Mods = case file:consult(AppFile) of
        {ok, [{application, ebloomd, Props}]} ->
            proplists:get_value(modules, Props, []);
        {error, _Reason} ->
            error ("Failed to load included modules from ebloomd.app")
    end,

    % From the list obtain only those for which there was modification,
    Modified = lists:filter(fun module_modified/1, Mods),

    % Make sure that no module is dangling in old code
    case [Mod || Mod <- Modified, code:soft_purge(Mod) =:= false] of
        % All modules are in current code, safe to reload,
        [] ->
            % Make the newly compiled files the load path,
            code:set_path(LoadPaths),

            % Update all modules.
            [code:load_file(Mod) || Mod <- Modified],
            {_Success = 0, "Successfully reloaded."};
        OldMods ->
            Msg = io_lib:format("Failed to reload! Modules in old code: ~p.~n",
                [OldMods]),
            {_Failure = 1, Msg}
    end.



% The following three functions are from Wings3D. No documentation provided.
% Their LICENSE:
% This software is copyrighted by Bjorn Gustavsson, and other parties.
% The following terms apply to all files associated with the software unless
% explicitly disclaimed in individual files.
%
% The authors hereby grant permission to use, copy, modify, distribute,
% and license this software and its documentation for any purpose, provided
% that existing copyright notices are retained in all copies and that this
% notice is included verbatim in any distributions. No written agreement,
% license, or royalty fee is required for any of the authorized uses.
% Modifications to this software may be copyrighted by their authors
% and need not follow the licensing terms described here, provided that
% the new terms are clearly indicated on the first page of each file where
% they apply.
%
% IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
% FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
% ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
% DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
% IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
% NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
% MODIFICATIONS.
%
% GOVERNMENT USE: If you are acquiring this software on behalf of the
% U.S. government, the Government shall have only "Restricted Rights"
% in the software and related documentation as defined in the Federal
% Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
% are acquiring the software on behalf of the Department of Defense, the
% software shall be classified as "Commercial Computer Software" and the
% Government shall have only "Restricted Rights" as defined in Clause
% 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
% authors grant the U.S. Government and others acting in its behalf
% permission to use and distribute the software in accordance with the
% terms specified in this license.

module_modified(Module) ->
    case code:is_loaded(Module) of
        {file, preloaded} -> false;
        {file, Path} ->
            CompileOpts = proplists:get_value(compile, Module:module_info()),
            CompileTime = proplists:get_value(time, CompileOpts),
            Src = proplists:get_value(source, CompileOpts),
            module_modified(Path, CompileTime, Src);
        _ -> false
    end.


module_modified(Path, PrevCompileTime, PrevSrc) ->
    case find_module_file(Path) of
        false -> false;
        ModPath ->
            {ok, {_, [{_, CB}]}} = beam_lib:chunks(ModPath, ["CInf"]),
            CompileOpts =  binary_to_term(CB),
            CompileTime = proplists:get_value(time, CompileOpts),
            Src = proplists:get_value(source, CompileOpts),
            not ((CompileTime == PrevCompileTime) and (Src == PrevSrc))
    end.


find_module_file(Path) ->
    case file:read_file_info(Path) of
        {ok, _} -> Path;
        _ ->
            case code:where_is_file(filename:basename(Path)) of
                non_existing -> false;
                NewPath -> NewPath
            end
    end.
