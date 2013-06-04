-module(core_vars_simpler).

-export([main/1]).

main(File) ->
	{ok,_,Core} = compile:file(File,[to_core,binary,no_copt]),
	Vars = cerl_trees:fold(fun variables_fun/2,[],Core),
	%Vars = variables(Core),
	io:format("~p\n",[ordsets:to_list(Vars)]).


variables_fun(T,OrdSet) ->
	ordsets:union(variables(T),OrdSet).

variables(T) ->
    case cerl:type(T) of
		var ->
			remove_cors_funvars(cerl:var_name(T));
		_ ->
			[]
    end.

%% Remove core variables and function name variables

remove_cors_funvars({_,_}) ->
	[];
remove_cors_funvars(VarName) ->
	case atom_to_list(VarName) of 
		[$c,$o,$r|_] ->
			[];
		_ ->
    		[VarName]
    end.
