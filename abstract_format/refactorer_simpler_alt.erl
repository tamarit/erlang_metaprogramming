-module(refactorer_simpler_alt).

-export([ref_append/1]).


ref_append(File) ->
	{ok, Forms} = epp:parse_file(File, [], []),
    Comments = erl_comment_scan:file(File),
    NForms = 
		[erl_syntax_lib:map(
			fun ref_append_expr/1,
			Form) || Form <- Forms],
    FinalForms = erl_recomment:recomment_forms(NForms,Comments),
    io:format("~s\n",[erl_prettypr:format(FinalForms)]).

ref_append_expr(T) ->
	case erl_syntax:type(T) of 
		'infix_expr' ->
			case erl_syntax:operator_name(erl_syntax:infix_expr_operator(T)) of 
				'++' ->
					LeftOp = erl_syntax:infix_expr_left(T),
					RightOp = erl_syntax:infix_expr_right(T),
					CheckRight = 
						fun() ->
							case erl_syntax:type(RightOp) of 
								'nil' ->
									LeftOp;
								'string' ->
									case erl_syntax:string_value(RightOp) of 
										"" -> 
											LeftOp;
										_ -> 
											T
									end;
								_ -> 
									T
							end
						end,
					case erl_syntax:type(LeftOp) of 
						'nil' ->
							RightOp;
						'list' ->
							case erl_syntax:type(erl_syntax:list_tail(LeftOp)) of 
								'nil' ->
									erl_syntax:list(
										[erl_syntax:list_head(LeftOp)],
										RightOp);
								_ ->
									CheckRight()
							end;
						'string' ->
							case erl_syntax:string_value(LeftOp) of 
								"" -> 
									RightOp;
								[Char] ->
									case erl_syntax:type(RightOp) of 
										'string' ->
											erl_syntax:string(
												[Char|erl_syntax:string_value(RightOp)]);
										_ ->
											erl_syntax:list(
												[erl_syntax:integer(Char)],
												RightOp)
									end;
								_ -> 
									CheckRight()
							end;
						_ ->
							CheckRight()
					end;
				_ ->
					T
			end;
		_ ->
			T
	end.
