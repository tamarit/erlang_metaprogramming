-module(core_from_module).

-export([main/1]).

main(ModName) ->
	FileAdress = code:where_is_file(atom_to_list(ModName)++".erl"),
	NFileAdress = 
	   case FileAdress of
	        non_existing -> 
	     		NFileAdress_ = code:where_is_file(atom_to_list(ModName)++".beam"),
	     		case NFileAdress_ of
	     		     non_existing -> 
	     		     	throw({error,"Non existing module",ModName});
	     		     _ -> 
	     		     	RelPath = "ebin/" ++ atom_to_list(ModName) ++ ".beam",
	     		     	PrevPath = 
	     		     	   lists:sublist(NFileAdress_,1,
	     		     	                 length(NFileAdress_)-length(RelPath)),
	     		     	NRelPath = "src/" ++ atom_to_list(ModName) ++ ".erl",
	     		     	PrevPath ++ NRelPath
	     		end;
	     	_ -> FileAdress
	   end,
	element(3,compile:file(NFileAdress,[to_core,binary,no_copt])).
