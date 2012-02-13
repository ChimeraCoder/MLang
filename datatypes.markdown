Datatypes
========

In MLang, everything, including the code itself, is represented as either a primitive datatype, or a module. Modules are themselves compositions of other modules or of primitives, so everything, including the code itself, has a recursive representation as a primitive datatype.



Music Modules
========

Below is a list of the music modules that we would like to be able to support.

###Primitives

#####Note
A note has a specified pitch (wave frequency) and duration (temporal length). 

The duration is specified as an exact time, in seconds (or part thereof). Changes to the tempo are represented as functional transformations of the note duration. That is, if a particular note has a duration of 500ms, by default a 'play' function will play the note for 500ms. If the tempo is doubled, a 'play' function will only play that note for 250ms.

In this way, notes themselves are blissfully unware of the current state of the music, which keeps the code functional. The tempo is a parameter to the 'play' function, and in this way the same note can be shared by many separte calls to the 'play' function, since they do not modify the note itself.

The note itself can be treated as if it were immutable for most use cases. 

Notes may have a frequency above the threshold of human hearing (currently defined as 20,000 Hz). However, these frequencies will not be played. Instead, these frequencies are reserved for functions. In other words, there is no intrinsic difference between the internal representations of a note and a function. Both are simply expressions; the latter simply has frequency above a threshold (specified at compile-time). The interpreter will evaluate all expressions. Notes will evaluate to their pitch-duration, and functions will evaluate to the pitch-duration sequence(s) of the note(s) represented.


Therefore, in MLang, the terms 'note' and 'function' can be used interchangeably. For convenience, however, we will use the term 'note' to refer to a single pitch-duration value and 'function' to refer to a lambda-like function that evaluates to one or more notes (one or more pitch-duration values). 


Modules (discussed below) are simply compositions of notes/functions. (lGenerally, they will be combinations of functions.)


#####Function

See above - a function is *structurally* identical to a note.


As in other functional programming languages, functions do not 'return' values; they evaluate to values. (In MLang, they may evaluate to notes, modules, or other functions).





###Modules

**NB**: Notes (functions) are the only primitive in MLang, so everything that is not a note/function is a module.

Base modules are those that are built into the language. Below the base modules, some 'extra' modules are listed. There is no difference between the 'base' and 'extra' modules, except that we have already determined that the base modules are important enough that they should be built into the language, whereas we have not (yet) decided whether the 'extra' modules should be included in the standard MLang libraries by default.

As development of the language progresses, 'extra' modules may be moved to 'base'. 

#####Base

######Measure

All classical music is subdivided into measures, which are simply groups of notes. If there are multiple instruments/voices in a composition, the measure lengths for each instrument/voice must be identical (ie, all will 'start' a new measure at the same time).

In MLang, a measure consists of an arbitrary number of notes/functions with a fixed total duration. (Remember that tempo is defined at a higher level, so while the *relative* duration is fixed, the calling function may ultimately play the note for a different length of time.)

Because the total duration of a measure is fixed, it is known at compile-time.

Typically, at least in classical music, all measures in a composition will be the same length (duration). This is not an absolute requirement; however.


######Phrase

A phrase consists of an arbitrary number of notes/functions with an arbitrary total duration. The total duration of a phrase is not known at compile-time. A phrase may be a useful way to segregate or combine notes (or groups of notes), but it is not required.

Oftentimes, we will refer to the duration of individual phrases. Remember that the programmer/composer may very well know the duration of an individual phrase, even if there is no compile-time check. 

######Trill

A trill is a pair of notes that are played


####Extra

#####Simple Baroque Basso Ostinato

A Simple Baroque Basso Ostinato consists of two measures played by a bass (ie, the frequencies will be below a certain value). These two measures are intended to be repeated throughout the duration of the composition.

#####Sonata-Allegro Form

A song in Sonata-Allegro form consists of three portions. The first and third are related, so it is often referred to as A-B-A form. 

The first and second performance of the 'A' portion differ in that the second 'A' contains no repeated measures (if any exist), and the final few measures are oftentimes replaced with a slightly modified ending, as they become the end of the entire song.

The A portions are in a major key, whereas the B portion is in a minor key. Typically, the minor key for B will be the corresponding minor key for the major key of A, according to classical music theory (ie, C major -> A minor).


######Rondo (assuming parallelism)

A rondo consists of multiple (typically four) phrases with equal duration, intended to be played *in succession*. One instrument/voice begins playing the first phrase. As soon as it finishes the first phrase and starts the second, another instrument being playing the *first* phrase. This process continues, with each instrument beginning the first phrase as the 'previous' instrument finishes it and goes on to the next. As an instrument finishes the final phrase, it may being the first phrase again. Thus, the entire performance of a rondo may loop an arbitrary number of times.

A simple example of a Rondo is 'Row, Row, Row Your Boat'. 

######Canon (assuming parallelism)

A canon is similar to a rondo, except that the number of voices/instruments  may be less than the number of phrases.




