-module(core_vars_e).

-export([main/1]).


%MIRAR REMOVE CORE FUNVARS

%TYPES

%var_name() = integer() | atom() | {atom(), integer()}

%CompRet = ModRet | BinRet | ErrRet
%BinRet = {ok,ModuleName,Binary} | {ok,ModuleName,Binary,Warnings}
%ErrRet = error | {error,Errors,Warnings}

main(File) ->
	%compile:file(File, Options) -> CompRet
	%      with Options = [to_core,binary,no_copt]
	%
	%ordsets:to_list(ordset(T)) -> List(T)
	.

%ordsets:union/2
variables(T) ->
    case cerl:type(T) of
		literal ->
			;
		var ->
			%cerl:var_name(Node::cerl()) -> var_name()
			;
		values ->
			%cerl:values_es(Node::cerl()) -> [cerl()]
			;
		cons ->
			%cerl:cons_hd(C_cons::cerl()) -> cerl()
			%cerl:cons_tl(C_cons::cerl()) -> cerl()
			;
		tuple ->
			%cerl:tuple_es(C_tuple::cerl()) -> [cerl()]
			;
		'let' ->
			%cerl:let_arg(Node::cerl()) -> cerl()
			%cerl:let_body(Node::cerl()) -> cerl()
			%cerl:let_vars(Node::cerl()) -> [cerl()]
			;
		seq ->
			%cerl:seq_arg(Node::cerl()) -> cerl()
			%cerl:seq_body(Node::cerl()) -> cerl()
			;
		apply ->
			%cerl:apply_op(Node::cerl()) -> cerl()
			%cerl:apply_args(Node::cerl()) -> [cerl()]
		    ;
		call ->
			%cerl:call_module(Node::cerl()) -> cerl()
			%cerl:call_name(Node::cerl()) -> cerl()
			%cerl:call_args(Node::cerl()) -> [cerl()]
			;
		primop ->
		    %cerl:primop_args(Node::cerl()) -> [cerl()]
		    ;
		'case' ->
			%cerl:case_arg(Node::cerl()) -> cerl()
			%cerl:case_clauses(Node::cerl()) -> [cerl()]
			;
		clause ->
			%cerl:clause_guard(Node::cerl()) -> cerl()
			%cerl:clause_body(Node::cerl()) -> cerl()
			%cerl:clause_pats(Node::cerl()) -> [cerl()]
			;
		'fun' ->
			%cerl:fun_body(Node::cerl()) -> cerl()
			%cerl:fun_vars(Node::cerl()) -> [cerl()]
			;
		module ->
			%cerl:module_exports(Node::cerl()) -> [cerl()]
			%module_defs(Node::cerl()) -> [{cerl(), cerl()}]
			%cerl:module_vars(Node::cerl()) -> [cerl()]
    end.


%vars_in_list([cerl()]) -> ordset(var_name())
vars_in_list(Ts) ->
    vars_in_list(Ts, []).

vars_in_list([T | Ts], A) ->
    vars_in_list(Ts, ordsets:union(variables(T), A));
vars_in_list([], A) ->
    A.

%% Note that this function only visits the right-hand side of function
%% definitions.

%vars_in_defs([{cerl(), cerl()}]) -> ordset(var_name())
vars_in_defs(Ds) ->
    vars_in_defs(Ds, []).

vars_in_defs([{_, F} | Ds], A) ->
    vars_in_defs(Ds, ordsets:union(variables(F), A));
vars_in_defs([], A) ->
    A.

%% This amounts to insertion sort. Since the lists are generally short,
%% it is hardly worthwhile to use an asymptotically better sort.

%var_list_names([cerl()]) -> ordset(var_name())
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

%% Given a variable name Remove core variables and function name variables

%remove_cors_funvars(var_name()) -> [var_name()]
remove_cors_funvars({_,_}) ->
	[];
remove_cors_funvars(VarName) ->
	case atom_to_list(VarName) of 
		[$c,$o,$r|_] ->
			[];
		_ ->
    		[VarName]
    end.
