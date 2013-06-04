-module(core_to_abstract_bad).

-export([main/1]).

main(File) ->
	% {ok, Forms_} = epp:parse_file(File, [], []),
	% Forms = line_changer_pt:parse_transform(Forms_,[]),
	{ok, Forms} = epp:parse_file(File, [], []),
	{ok,_,Core} = compile:forms(Forms,[to_core,binary,no_copt]),
	CoreAbstracts = cerl_trees:fold(fun get_abstract/2,[],Core),
	CleanCoreAbstracts = [{CoreE,AbstE} || {CoreE,AbstE} <- CoreAbstracts, AbstE =/= []],
	io:format("~p\n",[lists:reverse(CleanCoreAbstracts)]).


get_abstract(Core,Acc) ->
	LineFile =
		case cerl:get_ann(Core) of 
			[_,Line_,{file,File_}] ->
				 [Line_,File_];
			[Line_,{file,File_}] ->
				[Line_,File_];
			[Line_,{file,File_},_] ->
				[Line_,File_];
			[_] ->
				[];
			[] ->
				[]
		end,
	case LineFile of 
		[] ->
			[{Core,[]} | Acc];
		[Line,File] ->
			Abstracts = get_expression_from_abstract(File,Line,cerl:type(Core)),
			[{Core,Abstracts} | Acc]
	end.


get_expression_from_abstract(File,Line,Type) ->
	% {ok, Forms_} = epp:parse_file(File, [], []),
	% Forms = line_changer_pt:parse_transform(Forms_,[]),
	{ok, Forms} = epp:parse_file(File, [], []),
	lists:flatten(
		[erl_syntax_lib:fold(
			fun(Tree,Acc) -> 
				%io:format("{Line,Tree}: ~p\n",[{Line,Tree}]),
	       		case Tree of 
	       			{'var',Line,_} when Type == 'var' ->
						[Tree|Acc];
	       			{'integer',Line,_} when Type == 'literal' ->
						[Tree|Acc];
					{'float',Line,_} when Type == 'literal' ->
						[Tree|Acc];
					{'string',Line,_} when Type == 'literal' ->
						[Tree|Acc];
					{'atom',Line,_} when Type == 'literal' ->
						[Tree|Acc];
					{'call',Line,_,_} when Type == 'call' ->
						[Tree|Acc];
					{'op',Line,_,_,_} when Type == 'call' ->
						[Tree|Acc];
					{'op',Line,_,_} when Type == 'call' ->
						[Tree|Acc];
	       			{'cons',Line,_,_} when Type == 'cons' ->
						[Tree|Acc];
					{'tuple',Line,_} when Type == 'tuple' ->
						[Tree|Acc];
					{'match',Line,_,_}  when Type == 'match' ->
						[Tree|Acc];
					{'case',Line,_,_} when Type == 'case' ->
						[{Tree,"Case"}|Acc];
					{'if',Line,_} when Type == 'case' ->
						[{Tree,"If"}|Acc];
					_ -> 
						Acc
	       		end
		     end, [], Form) || Form <- Forms]).

