-module(factorial).

-export([factorial/1]).

factorial(0) ->
	1;
factorial(N) when N > 0 ->
	mult(N,factorial(N-1)).

mult(_,0) ->
	0;
mult(X,1) ->
	X;
mult(X,Y) ->
	X + mult(X, Y - 1).