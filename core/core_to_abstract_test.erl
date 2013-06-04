-module(core_to_abstract_test).

-export([main/1]).

main(Y) ->
	X = {{1,Y},{1,Y}},
	Y = {f(X),f(Y)},
	case (case X of ok -> ok; _ -> X end) of 
		ok -> 
			if X > X+Y -> (X+Y) * 2; 
			   true -> [X] ++ [Y]
			end;
		_ ->
			element(1,(element(2,X)))
	end. 



f(G) -> {G,[G]}.