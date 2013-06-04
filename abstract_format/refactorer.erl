-module(refactorer).

-export([ref_append/1]).


ref_append(File) ->
	{ok, Forms} = epp:parse_file(File, [], []),
    FunForms = [Form || Form = {function,_,_,_,_} <- Forms],
    Attributes = [Form || Form = {attribute,_,_,_} <- Forms],
    Comments = erl_comment_scan:file(File),
    NFunForms = [ref_append_function(FunForm) || FunForm <- FunForms],
    FinalForms = erl_recomment:recomment_forms(Attributes ++ NFunForms,Comments),
    io:format("~s\n",[erl_prettypr:format(FinalForms)]).


 ref_append_function({function,LINE,Name,Arity,Clauses}) ->
 	{function,LINE,Name,Arity, [ref_append_clause(Clause) || Clause <- Clauses]}.

 ref_append_clause({clause,LINE,Pars,GuardsSeq,Exps}) ->
 	{clause,LINE,
 		[ref_append_expr(Par) || Par <- Pars],
 		[ [ref_append_expr(Guard) || Guard <- Guards] || Guards <- GuardsSeq],
 		[ref_append_expr(Exp) || Exp <- Exps]}.


ref_append_expr({op,_,'++',List,{nil,_}}) ->
	ref_append_expr(List);
ref_append_expr({op,_,'++',{nil,_},List}) ->
	ref_append_expr(List);
ref_append_expr({op,LINE,'++',{cons,_,Head,{nil,_}},Tail}) ->
	{cons,LINE,ref_append_expr(Head),ref_append_expr(Tail)};

ref_append_expr({op,_,'++',String,{string,_,[]}}) ->
	ref_append_expr(String);
ref_append_expr({op,_,'++',{string,_,[]},String}) ->
	ref_append_expr(String);
ref_append_expr({op,LINE,'++',{string,LINEHEAD,[Head]},Tail}) ->
	case ref_append_expr(Tail) of 
		{string,_,TailStr} ->
			{string,LINE,[Head|TailStr]};
		Other ->
			{cons,LINE,{integer,LINEHEAD,Head},Other}
	end;

ref_append_expr({op,LINE,Operator,Operand1,Operand2}) ->
	{op,LINE,Operator,ref_append_expr(Operand1),ref_append_expr(Operand2)};
ref_append_expr({cons,LINE,Head,Tail}) ->
	{cons,LINE,ref_append_expr(Head),ref_append_expr(Tail)};


ref_append_expr(Other) ->
	Other.

