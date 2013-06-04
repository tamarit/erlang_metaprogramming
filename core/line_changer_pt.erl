-module(line_changer_pt).
-export([parse_transform/2]).

parse_transform(Forms, _) -> 
    Attributes = [Form || Form = {attribute,_,_,_} <- Forms],
    FunForms = [Form || Form = {function,_,_,_,_} <- Forms],
	NFunForms = element(1, lists:mapfoldl(fun fun_change/2,1,FunForms)),
	%io:format("~p\n",[NFunForms]),
	Attributes ++ NFunForms.

fun_change(Form,CurrentId0) ->
	erl_syntax_lib:mapfold(
		fun(T,CurrentId) ->
			RevertedT = erl_syntax:revert(T),
			case {RevertedT, erl_syntax:is_tree(T)} of 
				{T,true} -> 
					{T,CurrentId};
				_ -> 
					{setelement(2, RevertedT, CurrentId) , CurrentId + 1}
			end
		end,
		CurrentId0 - 1,Form).