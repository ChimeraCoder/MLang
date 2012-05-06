(* Author: Nikhil Sarda *)

open Printf
open Mexp

module Midge = 
  struct
    type header = (int * int * int)
    type note = (int * Mexp.t * int)
    type channel = (int * int * int * note list)
	      and body = channel list

    let add_channel channel body =
      List.append body [channel]

    let add_note note channel =
      (fst channel, List.append (snd channel) [note])

    let rec string_of_mexp m =
      match m with
	Atom s -> s
      | Cons (c) ->
          begin
            let prolog = "("^(string_of_mexp (c.car)) in
            let rec loop s =
              match s with
                Cons (c1) ->
                  " "^(string_of_mexp (c1.car))^(loop (c1.cdr))
              | _ -> ""
            in
            prolog^(loop (cdr m))^")"
          end

    let print_midge file (temp, num, den) body =
      let count = ref 0 in
      let oc = open_out file in
        fprintf oc "@head { \n $time_sig %d/%d \n $tempo %d \n }" num den temp;
        fprintf oc "\n @body { \n";
        List.iter (fun (patch, volume, repeat, notes) ->
	  count := !count + 1;
	  fprintf oc " @channel %d { \n $patch %d $volume %d \n %%repeat %d { " !count patch volume repeat;
	  List.iter (fun (octave, note, length) -> fprintf oc " /l%d/%s%d " length (string_of_mexp note) octave) notes;
	  fprintf oc " \n } \n }") body;
        fprintf oc "\n }";
      close_out oc
  end;;
