open Mexp
open Environment
open Midge

let tee = (Atom "#T")

let nil = cons Null Null

let fn_car args _ = car (car args)

let fn_cdr args _ = cdr (car args)

let fn_quote args _ = car args

let fn_cons args _ =
  let lst = cons (car args) Null in

  let rec loop a =
    match a with
        Cons (_) ->
          begin
            append lst (car a) ;
            loop (cdr a)
          end
    | _ -> lst
  in
    loop (car (cdr args))

let fn_setcar args _ =
  let first = car args in
  let second = car (cdr args) in
    (match first with
         Cons (c) ->
           c.car <- second
    | _ -> invalid_arg "First argument to setcar must be a Cons") ;
    tee

let fn_setcdr args _ =
  let first = car args in
  let second = car (cdr args) in
    (match first with
        Cons (c) ->
          c.cdr <- second
    | _ -> invalid_arg "First argument to setcdr must be a Cons") ;
    tee
   
let fn_atom args _ =
  match (car args) with
      Atom (_) -> tee
  | _ -> nil

let fn_inc args _ =
  Atom (string_of_int (int_of_mexp (car args) + 1))

let fn_dec args _ =
  Atom (string_of_int (int_of_mexp (car args) - 1))

let rec fn_lambda args env =
  let lambda = (car args) in
  let rest = (cdr args) in
    match lambda with
        Lambda (largs, lmexp) ->
          let lst = interleave largs rest in
          let mexp = replace_atom lmexp lst in
            eval mexp env
    | _ -> invalid_arg "Argument to lambda must be a Lambda"
and eval mexp env =
  match mexp with
      Null -> nil
  | Cons (_) ->
        (match (car mexp) with
             Atom ("LAMBDA") ->
               let largs = car (cdr mexp) in
               let lmexp = car (cdr (cdr mexp)) in
                 Lambda (largs, lmexp)
        | _ ->
               let acc = cons (eval (car mexp) env) Null in
               let rec loop s =
                 match s with
                     Cons (_) ->
                       append acc (eval (car s) env) ;
                       loop (cdr s)
                 | _ -> ()
               in
                 loop (cdr mexp) ;
                 eval_fn acc env)
  | _ ->
        let v = Symtab.lookup env (name mexp) in
          match v with
              Null -> mexp
	  | Lambda (_) ->
	      v
          | _ -> v
              
and eval_fn mexp env =
  let symbol = car mexp in
  let args = cdr mexp in
    match symbol with
        Lambda (_) ->
          fn_lambda mexp env
    | Func (fn) ->
          (fn args env)
    | _ -> mexp

let fn_equal args env =
  let first = car args in
  let second = car (cdr args) in
    if (name (eval first env)) = (name (eval second env)) then
      tee
    else
        nil

let fn_cond args env =
  let rec loop a =
    match a with
        Cons (_) ->
          begin
            let lst = car a in
            let pred = (if (car lst) != nil then
                          eval (car lst) env
                        else
                          nil)
            in
            let ret = car (cdr lst) in
              if pred != nil then
                eval ret env
              else
                loop (cdr a)
          end
    | _ -> nil
  in
    loop args

let fn_ifelse args env =
  tee

let fn_label args env =
  Symtab.add env (name (car args))
    (car (cdr args)) ;
  tee

let rec mlang_pprint mexp =
  match mexp with
      Null -> ()
  | Cons (_) ->
        begin
          print_string "(" ;
          mlang_pprint (car mexp) ;
          let rec loop s =
            match s with
                Cons (_) ->
                  print_string " " ;
                  mlang_pprint (car s) ;
                  loop (cdr s)
            | _ -> ()
          in
            loop (cdr mexp) ;
            print_string ")" ;
        end
  | Atom (n) ->
        print_string n
  | Lambda (largs, lmexp) ->
        print_string "(LAMBDA " ;
        mlang_pprint largs ;
        print_string " " ;
        mlang_pprint lmexp ;
        print_string ")" ;
  | _ ->
        print_string "Error."


let fn_reverse args _ =
  let mexp = car args in
  (*let rec loop a =
    match a with
      Null -> nil
    | Atom _ -> a
    | _ -> cons (loop (cdr a)) (car a)
  in loop mexp*)
  mexp_of_list (List.rev (list_of_mexp mexp))

let fn_midge_exp args env =
  let mg = (car args) in
  let head = car mg in
  let body = car (cdr mg) in
  mlang_pprint body;
  tee

let fn_combine args _ =
  let list1 = car (car args) in
  let list2 = car (cdr (car args)) in
  let rec loop list1 list2 =
    match list1 with
      Atom _ -> nil
    | Cons (c1) ->
	begin
          match list2 with
            Atom _ -> nil
          | Cons (c2) ->
              let rest = loop c1.cdr c2.cdr in
              cons (cons c1.car (cons c2.car Null)) rest
	  | _ -> nil
	end
    | _ -> nil
  in loop list1 list2

let rec loop s channel =
  match s with
    Cons (_) ->
      loop (cdr s) (Midge.add_note (4, car s, 3) channel)
  | _ -> channel

let rec mlang_midge mexp body =
  match mexp with
    Null -> body
  | Cons (_) ->
      Midge.add_channel (loop mexp (36, [])) body
  | _ ->
      body

let file_read ch =  
let lexbuf = Lexing.from_channel ch in
       Parser.main Lexer.token lexbuf

let fn_file args env = 
 let f = car args in
   match f with
   Atom n -> 
   let file = n in
     let chn = open_in n in
       let text = file_read chn in
          close_in chn;         
          eval text env
   | _ -> invalid_arg "Invalid file argument" 


let rec mlang_printf file oc mexp = 
   match mexp with
   Null -> output_string oc "";
  | Cons (_) ->
        begin
          output_string oc "(" ;
          mlang_printf file oc (car mexp) ;
          let rec loop s =
            match s with
                Cons (_) ->
                  output_string oc " " ;
                  mlang_printf file oc (car s) ;
                  loop (cdr s)
            | _ -> ()
          in
            loop (cdr mexp) ;
            output_string oc ")" ;
        end
  | Atom (n) ->
        output_string oc n ;
  | Lambda (largs, lmexp) ->
        output_string oc "#" ;
        mlang_printf file oc largs ;
        mlang_printf file oc lmexp
  | _ ->
        output_string oc "Error."

let fn_write args env = 
   let f = car (car args) in
     match f with 
       Atom n -> 
        let file = n in 
          let chan = open_out n in 
           let mexp = cdr (car args) in 
            let mexp_eval = eval (car mexp) env in
              mlang_printf file chan mexp_eval;
              close_out chan;
              mexp_eval; 
       |_ -> invalid_arg "Invalid argument"

let fn_length args _ =
  let length = length_of_mexp (car args)
      in Atom (string_of_int length)

let fn_nth args _ =
  let n = int_of_mexp (car args) in
  let mexp = car (cdr args) in
  let rec loop a n =
    match a with
      Atom _ -> nil
    | Cons (c) -> if n = 0 then c.car else loop c.cdr (n-1)
  in loop mexp n

let fn_last args _ =
  let mexp = car args in
  let n = length_of_mexp mexp in
  let rec loop a n =
    match a with
      Atom _ -> nil
    | Cons (c) -> if n = 0 then c.car else loop c.cdr (n-1)
  in loop mexp (n-1)

let fn_mapcar args env =
  let symbol = car args in
  let mexp = car (cdr args) in
  match symbol with
    Lambda (_) ->
      let rec apply symbol mexp =
	match mexp with
	  Atom a -> fn_lambda (cons symbol mexp) env
	| Cons (c) -> cons (fn_lambda (cons symbol (cons c.car Null)) env)
	      (apply symbol c.cdr)
	| _ -> mexp
      in apply symbol mexp
  | Func (fn) ->
      let rec apply_fn mexp =
	match mexp with
	  Atom a -> eval (cons symbol mexp) env
	| Cons (c) -> cons (fn (cons c.car Null) env) (apply_fn c.cdr) 
        | _ -> mexp
      in apply_fn mexp
  | _ -> args

let fn_reduce args env =
  let symbol = car args in
  let mexp = car (cdr args) in
  let initial = car (cdr (cdr args)) in
  tee
