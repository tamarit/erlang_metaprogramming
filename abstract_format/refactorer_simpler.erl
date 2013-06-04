-module(refactorer_simpler).

-export([ref_append/1]).


ref_append(File) ->
	{ok, Forms} = epp:parse_file(File, [], []),
    Comments = erl_comment_scan:file(File),
    NForms = 
		[erl_syntax_lib:map(
			fun ref_append_fun/1,
			Form) || Form <- Forms],
    FinalForms = erl_recomment:recomment_forms(NForms,Comments),
    io:format("~s\n",[erl_prettypr:format(FinalForms)]).

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

