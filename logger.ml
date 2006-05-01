(*                                                                            *)
(* 2005, 2006 (c) Anastasia Gornostaeva <ermine@ermine.pp.ru>                 *)
(*                                                                            *)

open Unix

let open_log (filename:string) =
   open_out_gen [Open_creat; Open_append] 0o644 filename

let reopen_log filename lout =
   let new_lout = open_log filename in
      close_out lout;
      new_lout

let out lout str =
   let time = Strftime.strftime "%d/%m/%Y %T " 
      ~tm:(localtime (gettimeofday ())) in
      output_string lout (time ^ str);
      flush lout
