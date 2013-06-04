-module(smerl_test).

-export([test/0]).

test() ->
	M1 = smerl:new(foo),
	{ok, M2} = smerl:add_func(M1, "bar() -> 1 + 1."),
	smerl:compile(M2),
	foo:bar().