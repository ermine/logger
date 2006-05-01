(*                                                                            *)
(* (c) 2006 Anastasia Gornostaeva <ermine@ermine.pp.ru>                       *)
(*                                                                            *)
(* 
   LOG WARN|DEBUG ld fmt args END
   LOG EXC ld exc END
*)

open Lexing

let warn_flag = ref false;;
let debug_flag = ref false;;
let exn_flag = ref false;;

let enable_warns () = warn_flag := true;;
let enable_debug () = debug_flag := true;;
let enable_exn () = exn_flag := true;;
let enable_all () = 
   warn_flag := true;
   debug_flag := true;
   exn_flag := true;;

let make_prt _loc str fmt args =
   let filename = !Pcaml.input_file in
   let lineno = let bp, _ = _loc in bp.pos_lnum in
   let fmt' =
      Printf.sprintf "%s:%d %s: %s\n" filename lineno str fmt in
   let pri = <:expr< Printf.sprintf $str:(String.escaped fmt')$ >> in
   let rec priloop arglist res = 
      match arglist with
	    [] -> res
	 |  a::restargs -> priloop restargs <:expr< $res$ $a$ >>
   in
      priloop args pri

EXTEND
   GLOBAL: Pcaml.expr;

   Pcaml.expr: LEVEL "top"
      [ [ l = logger; ";"; e = Pcaml.expr ->
	     (match l with
		 | <:expr< () >> -> e
		 | _ -> <:expr< do {$l$; $e$} >>)
	| l = logger ->
	     l
	]];

   logger:
      [ [ "LOG"; "EXC"; ld = LIDENT; exn = LIDENT; "END" ->
	     if !exn_flag then
		let prt = make_prt _loc "EXC" "%s"
		   [<:expr< Printexc.to_string $lid:exn$ >>] in
		   <:expr< match $lid:ld$ with
			 [ None -> ()
			 | Some log ->
			      Logger.out log $prt$ ] >>
	     else
		<:expr< () >>
	| "LOG"; r = UIDENT; ld = LIDENT; fmt = STRING; args = log_args ->
	     let flag =
		match r with
		   | "DEBUG" -> !debug_flag
		   | "WARN" -> !warn_flag
		   | "INFO" -> true
		   | _ -> Stdpp.raise_with_loc _loc
			(Failure "expected DEBUG|WARN|EXC")
	     in
		if flag then
		   let prt = make_prt _loc r fmt args in
		      <:expr< match $lid:ld$ with
			[  None -> ()
			 | Some log ->
			      Logger.out log $prt$ ] >>
		else
		   <:expr< () >>
	] ];
   log_args: 
      [[ "END"  -> []
	    (* the simple level is essential - otherwise all tracelist are
	       of length 1 (usually an application!) *)
       | e = Pcaml.expr LEVEL "simple" ; rest = log_args -> e::rest ] 
      ];
   END
;;

Pcaml.add_option "-log_warn" (Arg.Unit enable_warns) 
  "enab;e all warning messages (default: disabled"
;;
Pcaml.add_option "-log_debug" (Arg.Unit enable_debug) 
   "enable debug (default: disabled"
;;
Pcaml.add_option "-log_exc" (Arg.Unit enable_exn) 
   "enable printing exceptions (default: disabled"
;;
Pcaml.add_option "-log_all" (Arg.Unit enable_all) 
   "enable all messages (default: disabled"
;;
