type token =
  | NAME of (string)
  | LPAREN
  | RPAREN
  | EOF
  | EOL

open Parsing;;
let yytransl_const = [|
  258 (* LPAREN *);
  259 (* RPAREN *);
    0 (* EOF *);
  260 (* EOL *);
    0|]

let yytransl_block = [|
  257 (* NAME *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\003\000\003\000\005\000\005\000\004\000\
\000\000"

let yylen = "\002\000\
\001\000\001\000\001\000\002\000\003\000\001\000\002\000\001\000\
\002\000"

let yydefred = "\000\000\
\000\000\000\000\008\000\000\000\009\000\001\000\002\000\003\000\
\004\000\000\000\000\000\007\000\005\000"

let yydgoto = "\002\000\
\005\000\010\000\007\000\008\000\011\000"

let yysindex = "\004\000\
\002\255\000\000\000\000\255\254\000\000\000\000\000\000\000\000\
\000\000\002\255\003\255\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\004\255\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\007\000\000\000\000\000\255\255"

let yytablesize = 9
let yytable = "\003\000\
\004\000\009\000\003\000\004\000\001\000\013\000\006\000\006\000\
\012\000"

let yycheck = "\001\001\
\002\001\003\001\001\001\002\001\001\000\003\001\003\001\001\000\
\010\000"

let yynames_const = "\
  LPAREN\000\
  RPAREN\000\
  EOF\000\
  EOL\000\
  "

let yynames_block = "\
  NAME\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mexp) in
    Obj.repr(
# 9 "parser.mly"
                                     ( _1 )
# 74 "parser.ml"
               : Mexp.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 13 "parser.mly"
                                     ( _1 )
# 81 "parser.ml"
               : 'mexp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'atom) in
    Obj.repr(
# 14 "parser.mly"
                                     ( _1 )
# 88 "parser.ml"
               : 'mexp))
; (fun __caml_parser_env ->
    Obj.repr(
# 18 "parser.mly"
                                     ( Mexp.Null )
# 94 "parser.ml"
               : 'list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'list_contents) in
    Obj.repr(
# 19 "parser.mly"
                                     ( _2 )
# 101 "parser.ml"
               : 'list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mexp) in
    Obj.repr(
# 22 "parser.mly"
                                     ( Mexp.cons _1 Mexp.Null )
# 108 "parser.ml"
               : 'list_contents))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'mexp) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'list_contents) in
    Obj.repr(
# 23 "parser.mly"
                                     ( Mexp.cons _1 _2 )
# 116 "parser.ml"
               : 'list_contents))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 27 "parser.mly"
                                     ( Mexp.Atom _1 )
# 123 "parser.ml"
               : 'atom))
(* Entry main *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let main (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Mexp.t)
