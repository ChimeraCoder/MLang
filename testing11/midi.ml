module type MMIDI =
    sig
        open Stream
        (** MIDI data exception thrown when input data does not adhere to standard *)
        exception MIDI_data of string

        (********************************************************************)
        (* Type Definitions                                                 *)
        type midievent =          NoteON of (int * int)
          |         NoteOFF of (int * int)
          |     KeyPressure of (int * int)
          |   ControlChange of (int * int)
          |   ProgramChange of int
          | ChannelPressure of int
          |       PitchBend of (int * int)
          |  SequenceNumber of int
          |       TextEvent of string
          | CopyrightNotice of string
          |       TrackName of string
          |  InstrumentName of string
          |           Lyric of string
          |          Marker of string
          |        CuePoint of string
          |       PatchName of string
          |        PortName of string
          |  MIDIChanPrefix of int
          |  MIDIPortPrefix of int
          |      EndOfTrack
          |           Tempo of int
          |     SMPTEOffset of (int * int * int * int * int)
          |   TimeSignature of (int * int * int * int)
          |    KeySignature of (int * int)
          |     Proprietary of int list
          | SystemExclusive of int list
          | MTCQuarterFrame of int
          |    SongPosition of int * int
          |      SongSelect of int
          |     TuneRequest of int
          |       MIDIClock
          |        MIDITick
          |       MIDIStart
          |    MIDIContinue
          |        MIDIStop
          |     ActiveSense
             (** a MIDI track contains MIDI events of the form (delta time since
                 last event, channel number of event (0 for non-channel events,
                 midievent *)
             and track =       (int * int * midievent) list
             (** a MIDI structure is a tuple with (division, tracks) *)
             and midi  = int * track list;;

        (** read a MIDI file into a midi structure *)
        val read  : string -> midi
        (** write the midi structure out to a MIDI file *)
        val write : midi -> string -> unit
    end;;

module MIDI : MMIDI = struct

    open Stream;;
    exception MIDI_data of string;;

    (**************************************************************************)
    (* Type Definitions                                                       *)
    (** midi events occur within the tracks of a midi file *)
    type midievent =          NoteON of (int * int)
      |         NoteOFF of (int * int)
      |     KeyPressure of (int * int)
      |   ControlChange of (int * int)
      |   ProgramChange of int
      | ChannelPressure of int
      |       PitchBend of (int * int)
      |  SequenceNumber of int
      |       TextEvent of string
      | CopyrightNotice of string
      |       TrackName of string
      |  InstrumentName of string
      |           Lyric of string
      |          Marker of string
      |        CuePoint of string
      |       PatchName of string
      |        PortName of string
      |  MIDIChanPrefix of int
      |  MIDIPortPrefix of int
      |      EndOfTrack
      |           Tempo of int
      |     SMPTEOffset of (int * int * int * int * int)
      |   TimeSignature of (int * int * int * int)
      |    KeySignature of (int * int)
      |     Proprietary of int list
      | SystemExclusive of int list
      | MTCQuarterFrame of int
      |    SongPosition of int * int
      |      SongSelect of int
      |     TuneRequest of int
      |       MIDIClock
      |        MIDITick
      |       MIDIStart
      |    MIDIContinue
      |        MIDIStop
      |     ActiveSense
             (** a MIDI track contains MIDI events of the form (delta time since
                 last event, channel number of event (0 for non-channel events,
                 midievent *)
             and track =       (int * int * midievent) list
             (** a MIDI structure is a tuple with (division, tracks) *)
             and midi  = int * track list;;

    (** read a MIDI file into a midi structure *)
    let read inFile =
        let ip = open_in_bin inFile in
        let strm = Stream.of_channel ip in
        (* discard: throw away num bytes *)
        let rec discard num = if num<1 then () else (junk(strm); discard (num-1))
        (* ipeek : peek that returns the integer value of char from stream *)
        and ipeek xs =
            match peek(strm) with
            | Some c -> Some (Char.code c)
            | None -> None
        (* inpeek : npeek that returns a list of n integers *)
        and inpeek n = List.map (fun x -> Char.code x) (npeek n strm) 
        (* add7bit : 7 bit number addition *)
        and add7bit x sum = ((sum lsl 7) lor (x land 127))
        (* add8bit : 8 bit number addition *)
        and add8bit x sum = ((sum lsl 8) lor x) in
        (* bytes2int : extract num bytes from stream and convert to a number *)
        let bytes2int num =
            let rec b2i num ans = if num<1 then ans else 
                match ipeek(strm) with
                | Some v -> junk(strm); b2i (num-1) (add8bit v ans)
                | None   -> ans
            in b2i num 0
        (* bytes2list : extract num bytes from stream *)
        and bytes2list num =
            let rec b2l num ans = if num < 1 then List.rev(ans) else
                match ipeek(strm) with
                | Some b -> junk(strm); b2l (num-1) (b::ans)
                | None -> List.rev(ans)
            in b2l num [] in
        (* bytes2string : extract num bytes from stream and convert to a string *)
        let bytes2string num =
            let bs = bytes2list num in
            let s = String.create (List.length bs) in
            let rec f pos xs =
                match xs with
                | x::zs -> s.[pos] <- (Char.chr x); f (pos+1) zs
                |  []   -> ();
            in f 0 bs; s in
        (* getTrack : convert the next bytes of the stream to a midi track. Note  *)
        (*            that numBytes is not the number of bytes to read, but rather*)
        (*            the actual position in the stream to stop reading. THis is  *)
        (*            a tail recursive function with optrk the output             *)
        let rec getTrack numBytes optrk =
            (* limpeek: limited by track length, return None if numBytes was read *)
            let limpeek xs = if count(strm) > numBytes then None else ipeek xs in
            (* limnpeek: limited npeek, returns no bytes after numBytes read      *)
            let limnpeek num =
                if count(strm) > numBytes then [] else
                let lim = (numBytes - count(strm)) in
                let n = if lim < num then lim else num in inpeek n in
            (* getList : get a list of integers of length len from the stream     *)
            let getList len = let xs = limnpeek len in discard (List.length xs); xs in
            (* getNum : get a number of len bytes from the stream                 *)
            let getNum len = List.fold_left (fun sum d -> add8bit d sum) 0 (getList len) in
            (* getString : get a string of len bytes from the stream              *)
            let getString len =
                let char2string c = let s = String.create 1 in s.[0] <- c; s in
                List.fold_left (fun n d -> (n^char2string(Char.chr d))) "" (getList len) in
            (* getVarInt : get a number of variable length from the stream        *)
            let getVarInt () =
                let rec f sum = match limpeek(strm) with
                | Some x -> junk(strm);
                        if x<128 then ((sum lsl 7) lor (x land 127))
                        else f ((sum lsl 7) lor (x land 127))
                | None -> raise (MIDI_data("EOF while reading delta"))
                in f 0 in
            (* isEnd : a kludge function to check for EndOfTrack sequence         *)
            let isEnd () = match (inpeek 3) with
            | 0xFF::0x2F::0x00::[] -> if (numBytes-count(strm))=3 then true else false
            | _ -> false in
            (* midiEvent : tail recursive function to read the track events from  *)
            (*             the stream. Supply prev_msg for midi running status    *)
            (*             where messages sent without the status byte are        *)
            (*             assumed to be the same type as the previous message    *)
            (*       Note: all events are concatenated in reverse order for speed *)
            (*             because :: operator is faster than @ operator          *)
            let rec midiEvent result prev_msg =
                (* back out if numBytes has been read *)
                if count(strm) >= numBytes then result else
                (* isEnd() is a kludge. after seeing one MIDI file with an *)
                (* EndTrack event with no delta time                       *)
                let delta = if isEnd() then 0 else getVarInt() in
                match limpeek(strm) with
                | Some 0xFF -> junk(strm);
                (   match (getList 2) with
                    (* Sequence Number 0xFF 0x00 0x02 :                           *)
                | 0x00::0x02::[] ->
                    (   match (getList 2) with
                    | s1::s2::zs -> midiEvent ((delta,0,SequenceNumber(add8bit s2 s1))::result) prev_msg
                    | _ -> raise (MIDI_data("Expected data for Sequence Number event"))
                    )
                    (* Text Event 0xFF 0x01 :                                     *)
                | 0x01::len ::[] -> let text = getString len in midiEvent ((delta,0,TextEvent(text))::result)  prev_msg
                    (* Copyright Notice 0xFF 0x02 :                               *)
                | 0x02::len ::[] -> let text = getString len in midiEvent ((delta,0,CopyrightNotice(text))::result) prev_msg
                    (* Sequence/Track Name 0xFF 0x03 :                            *)
                | 0x03::len ::[] -> let text = getString len in midiEvent ((delta,0,TrackName(text))::result) prev_msg
                    (* Instrument Name 0xFF 0x04 :                                *)
                | 0x04::len ::[] -> let text = getString len in midiEvent ((delta,0,InstrumentName(text))::result) prev_msg
                    (* Lyric 0xFF 0x05 :                                          *)
                | 0x05::len ::[] -> let text = getString len in midiEvent ((delta,0,Lyric(text))::result) prev_msg
                    (* Marker 0xFF 0x06 :                                         *)
                | 0x06::len ::[] -> let text = getString len in midiEvent ((delta,0,Marker(text))::result) prev_msg
                    (* Cue Point 0xFF 0x07 0x02 :                                 *)
                | 0x07::len ::[] -> let text = getString len in midiEvent ((delta,0,CuePoint(text))::result) prev_msg
                    (* Program (Patch) Name 0xFF 0x08 :                           *)
                | 0x08::len ::[] -> let text = getString len in midiEvent ((delta,0,PatchName(text))::result) prev_msg
                    (* Device (Port) Name 0xFF 0x09 :                             *)
                | 0x09::len ::[] -> let text = getString len in midiEvent ((delta,0,PortName(text))::result) prev_msg
                    (* MIDI Channel Prefix 0xFF 0x20 0x01 :                       *)
                | 0x20::0x01::[] -> let bb = getNum 1 in midiEvent ((delta,0,MIDIChanPrefix(bb))::result) prev_msg
                    (* Port Prefix 0xFF 0x20 0x01 :                               *)
                | 0x21::0x01::[] -> let bb = getNum 1 in midiEvent ((delta,0,MIDIPortPrefix(bb))::result) prev_msg
                    (* End of Track 0xFF 0x2F :                                   *)
                | 0x2F::0x00::[] -> midiEvent ((delta,0,EndOfTrack)::result) prev_msg
                    (* Tempo 0xFF 0x51 0x03 : t1*0x10000 + t2*0x100 + t3          *)
                | 0x51::0x03::[] -> let t = getNum 3 in midiEvent ((delta,0,Tempo(t))::result) prev_msg
                    (* SMPTE Offset 0xFF 0x54 0x05 :                              *)
                | 0x54::0x05::[] ->
                    (   match (getList 5) with
                    | hr::mn::se::fr::ff::[] -> midiEvent ((delta,0,SMPTEOffset(hr,mn,se,fr,ff))::result) prev_msg
                    | _ -> raise (MIDI_data("Expected time data for SMPTE event"))
                    )
                    (* Time Signature 0xFF 0x58 0x04 :                            *)
                | 0x58::0x04::[] ->
                    (   match (getList 4) with
                    | n::d::c::b::[] -> midiEvent ((delta,0,TimeSignature(n,d,c,b))::result) prev_msg
                    | _ -> raise (MIDI_data("Expected data for Time Signature event"))
                    )
                    (* Key Signature 0xFF 0x59 0x02 :                             *)
                | 0x59::0x02::[] ->
                    (   match (getList 2) with
                    | sf::mi::zs -> midiEvent ((delta,0,KeySignature(sf,mi))::result) prev_msg
                    | _ -> raise (MIDI_data("Expected data for Time Signature event"))
                    )
                    (* Sequencer Specific/Proprietary 0xFF 0x7F :                 *)
                | 0x7F::len::zs -> let d = getList len in midiEvent ((delta,0,Proprietary(d))::result) prev_msg
                | x::y::zs -> raise (MIDI_data("Invalid meta event encountered "^(string_of_int x)))
                | _ -> raise (MIDI_data("Stream error encountered "))
                )
                | Some x ->
                (   (* separate the channel message from the channel number       *)
                    let (msg,chan) = if (x>0x7F) then (junk(strm); ((x land 0xF0),(x land 0x0F))) else prev_msg in
                        match msg with
                        (* Note_OFF 0x8n : pitch and velocity bytes are 7bit => 0xxxxxxx. *)
                        | 0x80 ->
                        (   match (getList 2) with
                        | pitch::velocity::[] -> midiEvent ((delta,chan,NoteOFF((pitch land 0x7F),(velocity land 0x7F)))::result) (0x80,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading NOTE_OFF message "^(string_of_int (count(strm)))^" "^(string_of_int numBytes)))
                        )
                        (* Note_ON 0x9n : pitch,velocity are 7bit => 0xxxxxxx     *)
                        | 0x90 ->
                        (   match (getList 2) with
                        | pitch::velocity::[] -> midiEvent ((delta,chan,NoteON((pitch land 0x7F),(velocity land 0x7F)))::result) (0x90,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading NOTE_ON message"))
                        )
                        (* Key Pressure (Aftertouch) 0xA0 :pitch,pressure 7bit=> 0xxxxxxx *)
                        | 0xA0 ->
                        (   match (getList 2) with
                        | pitch::pressure::[] -> midiEvent ((delta,chan,KeyPressure((pitch land 0x7F),(pressure land 0x7F)))::result) (0xA0,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading KEY PRESSURE message"))
                        )
                        (* Control Change 0xB0 : control,value are 7bit => 0xxxxxxx       *)
                        | 0xB0 ->
                        (   match (getList 2) with
                        | control::value::[] -> midiEvent ((delta,chan,ControlChange((control land 0x7F),(value land 0x7F)))::result) (0xB0,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading CONTROL CHANGE message"))
                        )
                        (* Program Change 0xC0 : program byte is 7bit => 0xxxxxxx         *)
                        | 0xC0 ->
                        (   match (getList 1) with
                        | program::[] -> midiEvent ((delta,chan,ProgramChange(program land 0x7F))::result) (0xC0,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading PROGRAM CHANGE message"))
                        )
                        (* Channel Pressure 0xD0 : pressure byte is 7bit => 0xxxxxxx      *)
                        | 0xD0 ->
                        (   match (getList 1) with
                        | pressure::[] -> midiEvent ((delta,chan,ChannelPressure(pressure land 0x7F))::result) (0xD0,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading CHANNEL PRESSURE message"))
                        )
                        (* Pitch Bend 0xE0 : lsb and msb bytes are 7bit => 0xxxxxxx       *)
                        | 0xE0 ->
                        (   match (getList 2) with
                        | lsb::msb::[] -> midiEvent ((delta,chan,PitchBend((lsb land 0x7F),(msb land 0x7F)))::result) (0xE0,chan)
                        | _ -> raise (MIDI_data("Stream error encountered reading PITCH BEND message"))
                        )
                        | 0xF0 ->
                        (   match chan with
                            (* System Exclusive 0xF0 : first byte is manufacturer id *)
                        | 0x0 ->
                                let rec getData lst = match (limpeek strm) with
                                | Some 0xF7 -> junk(strm); List.rev(lst)
                                | Some x -> junk(strm); getData (x::lst) 
                                | None -> List.rev(lst) in
                                let ds = getData [] in midiEvent ((delta,chan,SystemExclusive(ds))::result) (0,0)
                            (* MTC Quarter Frame Message : one data byte follows *)
                        | 0x1 -> 
                                let bb = getNum 1 in midiEvent ((delta,chan,MTCQuarterFrame(bb))::result) (0,0)
                            (* Song Position Pointer *)
                        | 0x2 -> let aa = getNum 1 in let bb = getNum 1 in midiEvent ((delta,chan,SongPosition(aa,bb))::result) (0,0)
                            (* Song Select *)
                        | 0x3 -> let bb = getNum 1 in midiEvent ((delta,chan,SongSelect(bb))::result) (0,0)
                            (* Tune Request *)
                        | 0x6 -> let bb = getNum 1 in midiEvent ((delta,chan,TuneRequest(bb))::result) (0,0)
                            (* MIDI Clock *)
                        | 0x8 -> midiEvent ((delta,chan,MIDIClock)::result) prev_msg
                            (* MIDI Tick *)
                        | 0x9 -> midiEvent ((delta,chan,MIDITick)::result) prev_msg
                            (* MIDI Start *)
                        | 0xA -> midiEvent ((delta,chan,MIDIStart)::result) prev_msg
                            (* MIDI Continue *)
                        | 0xB -> midiEvent ((delta,chan,MIDIContinue)::result) prev_msg
                            (* MIDI Stop *)
                        | 0xC -> midiEvent ((delta,chan,MIDIStop)::result) prev_msg
                            (* MIDI Continue *)
                        | 0xE -> midiEvent ((delta,chan,ActiveSense)::result) prev_msg
                        | x -> midiEvent result (0,0) (* something bad happened if we end up here ! *)
                        )
                        | y -> result (* it's all gone wrong, how do we handle this case ?? *)
                )
                | None -> raise (MIDI_data("The input stream has died a bit too soon."))
            (* because all events are added in reverse order, reverse the list *)
            in List.rev (midiEvent [] (0,0))
        (* readTracks: read numTracks from the input stream *)
        and readTracks numTracks = 
            let rec rd num result =
                match num with
                | 0 -> List.rev(result)
                | _ ->
                (   match (inpeek 4) with
                    (* recognize, then discard the MTrk track header *)
                | 77::84::114::107::[] -> discard 4;
                        (* extract the length of the track *)
                        let len = bytes2int 4 in
                        (* read the track, giving it an offset in the stream to stop at *)
                        let trk = getTrack (count(strm) + len) [] in
                        rd (num-1) (trk::result)
                | _ -> raise (MIDI_data("Expected Track Chunk "))
                )
            in rd numTracks [] in
        (* data: extract the header information then get the tracks *)
        let data = match (inpeek 4) with
            (* expect a header MThd sequence *)
        | 77::84::104::100::[] -> discard 4;
                (* junk the next 4 byte header length. It is always 0 0 0 6 *)
                discard 4;
                (* extract the format, number of tracks, and the division value *)
                let mFormat = bytes2int 2 in
                let numTracks = bytes2int 2 in
                let division = bytes2int 2 in
                (* confirm that the format works with the numTracks value, though *)
                (* this may be heavy handed as it should not be hard to recover   *)
                let errchk =
                    match mFormat,numTracks with
                    | 0,1 | 1,_ | 2,_ -> true
                    | _,_ -> raise (MIDI_data("Invalid number of tracks in header for MIDI file format 0 : format="^(string_of_int mFormat)^" num tracks="^(string_of_int numTracks)))
                (* extract the midi file as a tuple *)
                in (division,readTracks numTracks)
        | _ -> raise (MIDI_data("Does not start with 'MThd', therefore not a MIDI tune"))
        in close_in ip; data;;

    (** write MIDI data to the supplied file name *) 
    let write data outFile =
        let chan = open_out_bin outFile in
        (* write : write a list of bytes to the open binary channel               *)
        let rec write xs = match xs with b::bs -> output_byte chan b; write bs | [] -> () in
        (* int2list : convert a integer to a list of numBytes length              *)
        let int2list num numBytes =
            let rec f n cnt result = if cnt<1 then result else f (n lsr 8) (cnt-1) ((n land 255)::result)
            in f num numBytes [] in
        (* varint2list : convert a integer to a variable length list              *)
        let varint2list ds =
            let rec dlta d lst =
                let dd = (d land 0x7F) in
                if lst=[] then dlta (d lsr 7) (dd::lst)
                else if d=0 then lst else dlta (d lsr 7) ((dd lor 0x80)::lst)
            in dlta ds [] in
        (* string2intlist : convert a string to a list of bytes                   *)
        let string2intlist str =
            let rec zoom pos lst =
                if pos<0 then lst else zoom (pos-1) ((Char.code str.[pos])::lst)
            in zoom ((String.length str) -1) [] in
        (* extract the division and tracks from the midi tuple                    *)
        let (division,tracks) = data in
        (* header : build and write the header information                        *)
        let header =
            let numTracks = List.length tracks in
            let format = if numTracks=1 then 0 else 1 in
            write (77::84::104::100::[]);
            write (0::0::0::6::[]);
            write (int2list format 2);
            write (int2list numTracks 2);
            write (int2list division 2) in
        (* toMIDI : convert a MIDI type to a sequence of bytes                    *)
        let toMIDI m =
            match m with
            | (delta,ch,          NoteOFF(x,y)) -> ((varint2list delta)@[0x80 lor ch;x;y])
            | (delta,ch,           NoteON(x,y)) -> ((varint2list delta)@[0x90 lor ch;x;y])
            | (delta,ch,      KeyPressure(x,y)) -> ((varint2list delta)@[0xA0 lor ch;x;y])
            | (delta,ch,    ControlChange(x,y)) -> ((varint2list delta)@[0xB0 lor ch;x;y])
            | (delta,ch,      ProgramChange(x)) -> ((varint2list delta)@[0xC0 lor ch;x])
            | (delta,ch,    ChannelPressure(x)) -> ((varint2list delta)@[0xD0 lor ch;x])
            | (delta,ch,        PitchBend(x,y)) -> ((varint2list delta)@[0xE0 lor ch;x;y])
            | (delta,ch,   SystemExclusive(xs)) -> ((varint2list delta)@[0xF0]@xs@[0xF7])
            | (delta,ch,    MTCQuarterFrame(x)) -> ((varint2list delta)@[0xF1;x])
            | (delta,ch,     SongPosition(x,y)) -> ((varint2list delta)@[0xF2;x;y])
            | (delta,ch,         SongSelect(x)) -> ((varint2list delta)@[0xF3;x])
            | (delta,ch,        TuneRequest(x)) -> ((varint2list delta)@[0xF6;x])
            | (delta,ch,             MIDIClock) -> ((varint2list delta)@[0xF8])
            | (delta,ch,              MIDITick) -> ((varint2list delta)@[0xF9])
            | (delta,ch,             MIDIStart) -> ((varint2list delta)@[0xFA])
            | (delta,ch,          MIDIContinue) -> ((varint2list delta)@[0xFB])
            | (delta,ch,              MIDIStop) -> ((varint2list delta)@[0xFC])
            | (delta,ch,           ActiveSense) -> ((varint2list delta)@[0xFE])
            | (delta,ch,     SequenceNumber(x)) -> ((varint2list delta)@[0xFF;0x00;0x02]@(int2list x 2))
            | (delta,ch,          TextEvent(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x01;List.length t]@t)
            | (delta,ch,    CopyrightNotice(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x02;List.length t]@t)
            | (delta,ch,          TrackName(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x03;List.length t]@t)
            | (delta,ch,     InstrumentName(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x04;List.length t]@t)
            | (delta,ch,              Lyric(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x05;List.length t]@t)
            | (delta,ch,             Marker(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x06;List.length t]@t)
            | (delta,ch,           CuePoint(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x07;List.length t]@t)
            | (delta,ch,          PatchName(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x08;List.length t]@t)
            | (delta,ch,           PortName(x)) -> let t = string2intlist x in ((varint2list delta)@[0xFF;0x09;List.length t]@t)
            | (delta,ch,     MIDIChanPrefix(x)) -> ((varint2list delta)@[0xFF;0x20;0x01;x])
            | (delta,ch,     MIDIPortPrefix(x)) -> ((varint2list delta)@[0xFF;0x21;0x01;x])
            | (delta,ch,            EndOfTrack) -> ((varint2list delta)@[0xFF;0x2F;0x00])
            | (delta,ch,              Tempo(x)) -> ((varint2list delta)@[0xFF;0x51;0x03]@(int2list x 3))
            | (delta,ch,SMPTEOffset(v,w,x,y,z)) -> ((varint2list delta)@[0xFF;0x54;0x05;v;w;x;y;z])
            | (delta,ch,TimeSignature(w,x,y,z)) -> ((varint2list delta)@[0xFF;0x58;0x04;w;x;y;z])
            | (delta,ch,     KeySignature(x,y)) -> ((varint2list delta)@[0xFF;0x59;0x02;x;y])
            | (delta,ch,        Proprietary(x)) -> ((varint2list delta)@[0xFF;0x7F]@(varint2list (List.length x))@x) in
        (* convertTrack : start by converting the track to a list of event byte   *)
        (*                lists. Then join all the individual event lists together*)
        let convertTrack t = List.fold_right (fun x xs -> x@xs) (List.map toMIDI t) [] in
        (* convert each track to a list of bytes                                  *)
        let tracks = List.map convertTrack tracks in
        (* addTrackHeader : tack on a track header to a list                      *)
        let addTrackHeader t = ((77::84::114::107::(int2list (List.length t) 4))@t) in
        (* addTrackHeader : tack on a track header to each track                  *)
        let tracks = List.map addTrackHeader tracks in
        (* write out each track to the output file                                *)
        let result = List.map write tracks in close_out chan; ();;

    end;;
