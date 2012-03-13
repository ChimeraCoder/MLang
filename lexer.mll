{
  open Parser
  exception Eof

  (*let keyword_table = Hashtbl.create 53
  let _ = List.iter (fun (k, v) -> Hashtbl.add keyword_table k v)
              [
		"add", KW1;
                "keyword", KW2;
                "here", KW3
	      ]*)
}

let alpha = ['A'-'z' '0'-'9' '*']+
let ident = alpha+ (alpha | ['_' '$'])*

rule token = parse
    [' ' '\t' '\n']                  { token lexbuf }
    | '('                            { LPAREN }
    | ')'                            { RPAREN }
    | ';' [^ '\n']*                  { token lexbuf } (* comments *)
    | alpha                          { NAME(Lexing.lexeme lexbuf) }
    | eof                            { raise Eof }
