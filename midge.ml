module Midge = 
  struct 
    type header = (int * int * int)
    type channel = (int * string list)
	      and body = channel list

    let add_channel channel body =
      List.append body [channel]

    let add_note note channel =
      (fst channel, List.append (snd channel) [note])
  end;;
