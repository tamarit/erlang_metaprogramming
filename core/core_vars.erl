-module(core_vars).

-export([main/1]).

main(File) ->
	{ok,_,Core} = compile:file(File,[to_core,binary,no_copt]),
	Vars = variables(Core),
	io:format("~p\n",[ordsets:to_list(Vars)]).

variables(T) ->
    case cerl:type(T) of
		literal ->
		    [];
		var ->
			remove_cors_funvars(cerl:var_name(T));
		values ->
		    vars_in_list(cerl:values_es(T));
		cons ->
		    ordsets:union(
		    	variables(cerl:cons_hd(T)),
				variables(cerl:cons_tl(T)));
		tuple ->
		    vars_in_list(cerl:tuple_es(T));
		'let' ->
		    ordsets:union(
		    	variables(cerl:let_arg(T)), 
		    	ordsets:union(
		    		variables(cerl:let_body(T)), 
		    		var_list_names(cerl:let_vars(T))));
		seq ->
		    ordsets:union(
		    	variables(cerl:seq_arg(T)),
				variables(cerl:seq_body(T)));
		apply ->
		    ordsets:union(
		      	variables(cerl:apply_op(T)),
		      	vars_in_list(cerl:apply_args(T)));
		call ->
		    ordsets:union(variables(cerl:call_module(T)),
				ordsets:union(
				    variables(cerl:call_name(T)),
				    vars_in_list(cerl:call_args(T))));
		primop ->
		    vars_in_list(cerl:primop_args(T));
		'case' ->
		    ordsets:union(variables(cerl:case_arg(T)),
				  vars_in_list(cerl:case_clauses(T)));
		clause ->
			ordsets:union(
				ordsets:union(
					variables(cerl:clause_guard(T)),
				    variables(cerl:clause_body(T))),
				vars_in_list(cerl:clause_pats(T)));
		'fun' ->
			ordsets:union(
				variables(cerl:fun_body(T)), 
				var_list_names(cerl:fun_vars(T)));
		module ->
		    ordsets:union(
		    	ordsets:union(
		    		vars_in_list(cerl:module_exports(T)),
		    		vars_in_defs(cerl:module_defs(T))),
		    	var_list_names(cerl:module_vars(T)))
    end.

vars_in_list(Ts) ->
    vars_in_list(Ts, []).

vars_in_list([T | Ts], A) ->
    vars_in_list(Ts, ordsets:union(variables(T), A));
vars_in_list([], A) ->
    A.

%% Note that this function only visits the right-hand side of function
%% definitions.

vars_in_defs(Ds) ->
    vars_in_defs(Ds, []).

vars_in_defs([{_, F} | Ds], A) ->
    vars_in_defs(Ds, ordsets:union(variables(F), A));
vars_in_defs([], A) ->
    A.

%% This amounts to insertion sort. Since the lists are generally short,
%% it is hardly worthwhile to use an asymptotically better sort.

var_list_names(Vs) ->
    var_list_names(Vs, []).

var_list_names([V | Vs], A) ->
	NA = 
		case remove_cors_funvars(cerl:var_name(V)) of 
			[] ->
				A;
			[VarName] ->
				ordsets:add_element(VarName, A)
		end,
    var_list_names(Vs, NA);
var_list_names([], A) ->
    A.

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
