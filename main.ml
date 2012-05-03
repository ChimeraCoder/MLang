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
               "CONS", fn_cons;
               "EQUAL", fn_equal;
               "ATOM", fn_atom;
               "COND", fn_cond;
               "LAMBDA", fn_lambda;
               "LABEL", fn_label;
	       "HEAD", fn_mg_defhead;
	       "CHANNEL", fn_mg_defchannel;
	       "BODY", fn_mg_defbody;
               "READ-FILE", fn_file;
               "WRITE-FILE", fn_write;
	       "LENGTH", fn_length;
	       "NTH", fn_nth;
	       "LAST", fn_last]
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
          Midge.print_midge "test.mg" (120, 4, 4) (mlang_midge mexp_eval []);
          print_newline () ;
      with
          Parsing.Parse_error -> print_endline "Parse error"
      | Lexer.Eof -> exit 0
    done
