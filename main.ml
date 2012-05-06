(* Author: Nikhil Sarda *)

open Mexp
open Builtins
open Environment
open Midge

let mlang_read inp =
  let lexbuf = Lexing.from_channel inp in
    Parser.main Lexer.token lexbuf
    
let init_env () =
  let env = Symtab.create 32 in
  let syms = [ "QUOTE", fn_quote;
               "CAR", fn_car;
               "CDR", fn_cdr;
	       "SETCAR", fn_setcar;
	       "SETCDR", fn_setcdr;
               "CONS", fn_cons;
               "EQUAL", fn_equal;
               "ATOM", fn_atom;
               "COND", fn_cond;
	       "IFELSE", fn_ifelse;
               "LAMBDA", fn_lambda;
               "LABEL", fn_label;
               "READ-FILE", fn_file;
               "WRITE-FILE", fn_write;
	       "LENGTH", fn_length;
	       "NTH", fn_nth;
	       "LAST", fn_last;
	       "MAPCAR", fn_mapcar;
	       "REDUCE", fn_reduce;
	       "INC", fn_inc;
	       "DEC", fn_dec;
	       "COMBINE", fn_combine;
	       "REVERSE", fn_reverse;
	       "CONCAT", fn_concat;
	       "MIDGE-EXPORT", fn_midge_exp]
  in
    List.iter (fun (name, sym) ->
                 Symtab.add env name (Func sym)) syms;
    env

let _ =
  let env = init_env () in
  let chin = stdin
  in
    while true do
      try
        print_string "> " ;
        flush stdout ;
        let mexp_eval = eval (mlang_read chin) env in
	  mlang_pprint mexp_eval;
          print_newline () ;
      with
          Parsing.Parse_error -> print_endline "Parse error"
      | Lexer.Eof -> exit 0
    done
