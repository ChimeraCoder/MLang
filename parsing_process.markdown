Parsing Process
===============


The following process may seem a bit roundabout at first - that's because it _is_ redundant. However, this is a good starting place, because it will give us a working starting point for the language.

The reason for the redundant steps is that it allows us to use MNotes in place of functions (as long as the MNotes are properly chosen, of course!). This equivalence is what allows us to implement the modularity intrinsic in MLang. 


#### 1. MLang Functions

The user inputs MLang functions (definitions and/or evaluations). This is the top-level input.


#### 2. MNotes

The interpreter evaluates the functions and converts them to a series of MNotes. MNotes are simply functions that take zero parameters and have a single (fixed) output. For example, the note A# (466 Hz) played for 50 ms might be expressed by the user as 

> %A
(note that the % is not part of the shell prompt, but rather a note-identifier).

The above is equivalent to something like

> ((lambda () '(466 50) ))

(Try it out for yourself, and you'll see that it's really just saying that the anonymous function takes zero parameters and always returns the two-element list '(466 50). Of course, our note literal representation might be a bit different from '(FREQ TIME), but you get the idea).

Unlike Lisp, the user will not need to use atomic values - MNotes are secretly lists of length 1 (for technical reasons), but the syntax will conceal this.

**NB:** This is _not_ a beta-reduction - it is simply encoding the lambda itself as a series of notes. This is analogous to encoding a Turing machine as a binary string so that it can be fed as the input to another Turing machine.


**NB:** There is _no_ type change occuring here. MLang functions are equivalent to MNotes, because the latter are simply zero-parameter functions. 

**NB:** Two sequences of notes may define the same function (or rather, two functions that have equivalent input/ouput), but a single function will always be encoded in the same way.

#### 3. OCaml Notes

There is a one-to-one correspondence between MNotes and OCaml notes. The stream of MNotes is fed to the OCaml interpreter, which is responsible for decoding the stream and creating an OCaml function (or multiple functions) that will be equivalent to the functions encoded in the MNote stream.

Some optimization may occur at this step, so it is _not_ necessary that every MLang function in the original input correspond to exactly one OCaml function at Stage #3, as long as the input-output relationship is honored. 


#### 4. OCaml Function Evaluation

At this stage, the functions themselves are evaluated (in OCaml).


