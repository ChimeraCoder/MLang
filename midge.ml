open Printf

module Midge = 
  struct 
    type header = (int * int * int)
    type channel = (int * string list)
	      and body = channel list

    let add_channel channel body =
      List.append body [channel]

    let add_note note channel =
      (fst channel, List.append (snd channel) [note])

    let print_midge file (temp, num, den) body =
      let count = ref 0 in
      let oc = open_out file in
        fprintf oc "@head { \n $time_sig %d/%d \n $tempo %d \n }" num den temp;
        fprintf oc "\n @body { \n";
        List.iter (fun (patch, notes) ->
	  count := !count + 1;
	  fprintf oc " @channel %d { \n $patch %d \n" !count patch;
	  List.iter (fun note -> fprintf oc " /l4/%s3 " note) notes;
	  fprintf oc " \n }") body;
        fprintf oc "\n }";
      close_out oc
  end;;
