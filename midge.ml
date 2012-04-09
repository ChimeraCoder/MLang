module Midge = 
  struct 
    type header = (int * int * int)
    type channel = (int * string list)
	      and body = channel list          
  end;;
