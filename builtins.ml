open Mexp
open Environment

(** Eventually, we will want to use a lambda expression instead of an atom to
 * represent the 'true' value **)
let tee = (Atom "#T")

(** We are already expressing the false value (nil) as an empty list, so the
 * 'conversion' to lambda expression is trivial **)
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

let fn_concatenate args _ = 
    (** Concatenating two (or more) notes is simply the same as placing them all
     * as elements within a list, since the notes in the list will be played
     * sequentially **)
    (cons (car args) (cdr args)) (**Currently, this is redundant, but it won't
    be later on. **)
      
let rec fn_recursive_mapcar args _ = 
    (** This function takes a SINGLE argument, which is a list of length 2.
     * The first argument is the function to be applied.
     * The second argument is the list of values to which it is to be applied.
     * **)
    '(operator (val1 val2 val3) (arg1 arg2... argn))
    if (car (cdr (cdr args))) = nil then
        (**If there are no more operands left, we are done, so return the result**)
        (car (cdr args))
    else
        let first_operand = (car (car (cdr (cdr args)))) in
          (** Flatten takes two lists and returns a single list of atoms **)
          (mapcar 
            operator 
            (flatten 
              (car (cdr args)) 
              (operator first_operand))
            (cdr args))


let rec fn_duration args _ = 
    (** Find the duration of the specified section of music **) 
    if (is_note args) then
        (note                      (* Create a note*) 
          50000                    (* The frequency is irrelevant*)
          (car (cdr (cdr args))))  (* The duration is the
        cumulative (recursive) duration **)
    else
      (**Args is not a note, so it is a list of notes/functions
       * and the duration of a list of notes/functions is the sum of the durations of the
       * individual notes/functions**)
      (reduce 
        (lambda 
          (x y) 
          (note 5000 (+ (atomic_duration x) (atomic_duration y)))) (** Atomic_duration
          returns a number, not a note *)
        args) 

let rec atomic_duration args _ = 
    (** This function is ONLY used internally - MLang programmers will never
     * use it, since they deal ONLY with notes (lists), and never numbers
     * directly **)
    (car (cdr (cdr args)))

let fn_is_note args _ = 
    (** This function takes an S-expression and checks if it is a note **)
    if (cdr args) = 0 then
        if (car (cdr args)) = note then
            (booleannote note) (**The argument itself is arbitrary, as long as
            it is not () **)
        else
            (booleannote ())
    else
        invalid_arg "Too many arguments passed"
    

let fn_boolean_note args _ = 
    (** This is a function that returns true if and only if the argument
     * is non-empty/non-nil **)
    if args = ()
        (falsenote)
    else
        (truenote)

let fn_truenote args _ =
    (** A lambda calculus formulation of 'true' **)
    (** Eventually, we will combine this with the definition of 'tee', so that
     * one evaluates to the other, thus ensuring that both have the same musical
     * representation **)
    (lambda (x) (lambda (y) x))

let fn_falsenote args _ = 
    (** A lambda calculus formulation of 'false' **)
    (lambda (x) (lambda (y) y))

let fn_if args _ = 
    (** Pattern matching and error catching needs to be done here, but as it
     * stands, this should provide correct output for any valid input
     * The three arguments in an if statement are the predicate, the value of
     * the entire expression if the predicate is true, and the value of the
     * entire expression if the predicate is false. 
     * Because the predicate is simply (car args), if the predicate is either
     * true or false, by the definitions of fn_truenote and fn_falsenote, then
     * the correct value will be chosen **)
    ((boolean (car args))       (** Evaluates to the appropriate lambda selector **)
      (car (cdr args))          (** The 'true' selector chooses this value **)
      (car (cdr (cdr args))))   (** The 'false' selector chooses this value **)

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

let fn_mg_defhead args env =
  print_string "Not implemented";
  nil

let fn_mg_defchannel args env =
  print_string "Not implemented";
  nil

let fn_mg_defbody channels env =
  print_string "Not implemented";
  nil
      
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
