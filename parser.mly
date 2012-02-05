%token <string> NAME
%token LPAREN RPAREN EOF EOL
%start main
%type <Mexp.t> main

%%

main:
  mexp                               { $1 }
  ;

mexp:
  list                               { $1 }
| atom                               { $1 }
;

list:
  LPAREN RPAREN                      { Mexp.null }
| LPAREN list_contents RPAREN        { $2 }

list_contents:
  | mexp                             { Mexp.mcons $1 Mexp.null }
  | mexp list_contents               { Mexp.cons $1 $2 }
;

atom:
  NAME                               { Mexp.Atom $1 }
;