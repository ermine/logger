(*
 * (c) 2006 Anastasia Gornostaeva <ermine@ermine.pp.ru>
 * 
 * LOG_FILE returns filename
 * LOG_LINE returns line number
 * LOG "somestring" is same for "%s:%d: something" FILE LINE
 *)

open Lexing

EXTEND
   GLOBAL: Pcaml.expr;

   Pcaml.expr: LEVEL "simple"
   [[ "LOG_FILE" ->
	 let filename = !Pcaml.input_file in
	    <:expr< $str:filename$ >>
    | "LOG_LINE" ->
	 let lineno = let bp, _ = _loc in bp.pos_lnum in
	    <:expr< $int:string_of_int lineno$ >>
    | "LOG"; fmt = STRING ->
	 let filename = !Pcaml.input_file
	 and lineno = let bp, _ = _loc in bp.pos_lnum in
	 let fmt' = filename ^ ":" ^ string_of_int lineno ^ ": " ^ fmt in
	    <:expr< $str:fmt'$ >>
    ]];
END
