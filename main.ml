open Builtins
open Environment
open Mexp

let mlang_read inp =
  let lexbuf = Lexing.from_channel inp in
    Parser.main Lexer.token lexbuf
    
let init_env () =
  let env = Symtab.create 32 in
  let syms = [ "PLAY", fn_quote;
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
	       "BODY", fn_mg_defbody]
  in
    List.iter (fun (name, sym) ->
                 Symtab.add env name (Func sym)) syms;
    env


let _ =
  let env = init_env () in
  let chin = stdin
  in let r = if Sys.file_exists("file.mlang") then Sys.remove("file.mlang") in
    while true do
      try
        print_string "> " ;
        flush stdout ;
        let file = "file.mlang" in
        let oc = open_out_gen [Open_wronly; Open_append; Open_creat; Open_text] 0o666 file in
        let mexp_eval = eval (mlang_read chin) env in
          mlang_printf file oc mexp_eval;
          mlang_pprint mexp_eval ;
          print_newline () ;
          close_out oc;
        with
          Parsing.Parse_error -> print_endline "Parse error";
          | Lexer.Eof -> mlang_play "f"; exit 0 ;
    done