open Mexp
open Environment

let tee = (Atom "#T")

let nil = cons Null Null

let fn_car args _ = car (car args)

let fn_cdr args _ = cdr (car args)

let fn_quote args _ = car args

let fn_double_length args _ = car (car args)

let fn_double_note args _ = 
    (* If the note is a single note, double the duration
     * Otherwise, double the duration of all notes contained
     *)
    let unwrapped = car args in
    (**If unwrapped is a single note, then (car unwrapped) will simply be note
     * **)
    if (car unwrapped) = note then
        (** Double a single note **)
        let pitch = (car (cdr unwrapped)) in
        let duration = (car (cdr (cdr unwrapped))) in
          if pitch = duration then
              pitch
          else
              nil
    else
        (** Double everything contained **)
        (** If unwrapped is not a single note, then it is a list of notes **)
        (**TODO it could also be a function **)
        (mapcar doublenote args)


let fn_mapcar args _ = 
    let operator = (car args) in
    let operands = (cdr args) in 
    let first_operand = (car operands) in
    let first_value = (operator first_operand) in 
       (cons first_value (mapcar operator (cdr operands)))

      



let fn_note args _ = cons (car args) (cons (cdr args) Null)

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

let fn_equal args _ =
  let first = car args in
  let second = car (cdr args) in
    if (name first) = (name second) then
      tee
    else
      nil
        
let fn_atom args _ =
  match (car args) with
      Atom (_) -> tee
  | _ -> nil

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
        print_string "#" ;
        mlang_pprint largs ;
        mlang_pprint lmexp
  | _ ->
        print_string "Error."
