-module(core_transformations).

-export([main/2]).


main(0,0) ->
	0;
main(X,Y) ->
	Z = h(f(X),g(Y)),
	io:format("~p\n",[Z]),
	{Z1,Z2} = Z,
	Res = Z1 + Z2,
	Res.


f(0) -> 0;
f(X) -> X.

g(X) -> X.

h(X,Y) -> {X,Y}.