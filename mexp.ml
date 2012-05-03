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
