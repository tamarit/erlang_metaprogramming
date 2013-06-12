-module(refactorer_test).

-export([test/0]).

test()->
	"" ++ ("c" ++ "ab"),
	[a] ++ [1,b],
	[b,"a" ++ "", c] ++ [],
	"a" ++ "b",
	%This case should remain the same
	[a,b] ++ [c],
	[] ++ [c],
	[1,2,3,4] -- ([1] ++ [2]),
	["" ++ "a"] ++ [2,4,"" ++ ""],
	[] ++ [],
	[2] ++ (([] ++ [3]) ++ [4]).