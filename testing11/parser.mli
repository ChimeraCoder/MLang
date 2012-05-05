type token =
  | NAME of (string)
  | LPAREN
  | RPAREN
  | EOF
  | EOL

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Mexp.t
