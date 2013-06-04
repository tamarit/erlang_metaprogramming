-module(refactorer_pt).

-export([parse_transform/2]).


parse_transform(Forms,_) ->
	[erl_syntax_lib:map(
		fun ref_append_fun/1,
		Form) || Form <- Forms].

ref_append_fun(T) ->
	ref_append_expr(erl_syntax:revert(T)).


ref_append_expr({op,_,'++',List,{nil,_}}) ->
	List;
ref_append_expr({op,_,'++',{nil,_},List}) ->
	List;
ref_append_expr({op,LINE,'++',{cons,_,Head,{nil,_}},Tail}) ->
	{cons,LINE,Head,Tail};

ref_append_expr({op,_,'++',String,{string,_,[]}}) ->
	String;
ref_append_expr({op,_,'++',{string,_,[]},String}) ->
	String;
ref_append_expr({op,LINE,'++',{string,LINEHEAD,[Head]},Tail}) ->
	case Tail of 
		{string,_,TailStr} ->
			{string,LINE,[Head|TailStr]};
		_ ->
			{cons,LINE,{integer,LINEHEAD,Head},Tail}
	end;

ref_append_expr(Other) ->
	Other.

