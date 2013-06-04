-module(core_from_expression).

-export([main/1]).

main(Expr) ->
	try
			{ok,Toks,_} = erl_scan:string(Expr++"."),
			{ok,[AExpr|_]} = erl_parse:parse_exprs(Toks),
    		cerl:abstract(erl_syntax:concrete(AExpr))
	catch
		_:_ -> 
			M1 = smerl:new(foo),
			{ok, M2} = smerl:add_func(M1,"bar() ->" ++ Expr ++ " ."),
			{ok,_,Core} = smerl:compile2(M2,[to_core,binary,no_copt]), 
			FunDefs = cerl:module_defs(Core), 
			FunBody = 
				hd([cerl:fun_body(FunDecl) || 
						{FunName,FunDecl} <- FunDefs, 
						cerl:var_name(FunName) == {bar,0}]),
			FirstClause = hd(cerl:case_clauses(FunBody)),
			cerl:clause_body(FirstClause)
	end.
