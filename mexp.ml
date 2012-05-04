type ('a, 'b) cell = { mutable car: 'a; mutable cdr: 'b }

type t = Atom of string
  | Cons of (t, t) cell
  | Func of (t -> (string, t) Hashtbl.t -> t)
  | Lambda of t * t
  | Null
             
let car o =
  match o with
      Cons (c) -> c.car
  | _ -> invalid_arg "bad argument when constructing mexp from car"

let cdr o =
  match o with
      Cons (c) -> c.cdr
  | _ -> invalid_arg "bad argument when constructing mexp from cdr"

let cons first second = Cons { car = first ; cdr = second }
  
let name o =
  match o with
      Atom (s) -> s
  | _ -> invalid_arg "bad argument when constructing mexp from name"

let string_of_mexp m =
  match m with
      Atom (s) -> s
  | _ -> "Mexp"

let int_of_mexp m =
  match m with
    Atom (s) -> int_of_string s
  | _ -> -1

let rec length_of_mexp m =
  match m with
      Atom "nil" -> 0
    | Cons (c) -> 1 + length_of_mexp (c.cdr)
    | _ -> 0

let rec list_of_mexp m =
  match m with
    Null -> []
  | Atom a -> [m]
  | Cons (c) -> List.append [c.car] (list_of_mexp c.cdr)

let rec mexp_of_list m =
  match m with
    [] -> Null
  | head::tail -> cons head (mexp_of_list tail)

let rec notes_of_mexp m =
  List.map (fun e ->
	   match e with
	    Cons (c) ->
	      let octave = int_of_mexp c.car in
	      let note = car c.cdr in
	      let rest = int_of_mexp (car (cdr (c.cdr))) in
	      (octave, note, rest)
	   | Atom _ -> (3, m, 4)
	   | _ -> (0, Null, 0)) (list_of_mexp m)

  
