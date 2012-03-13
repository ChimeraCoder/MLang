OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
INCLUDES=
OCAMLFLAGS=$(INCLUDES) -g
OCAMLOPTFLAGS=$(INCLUDES)

MAIN_OBJS=mexp.cmo parser.cmo lexer.cmo symtab.cmo environment.cmo builtins.cmo main.cmo

mlang: .depend $(MAIN_OBJS)
	$(OCAMLC) -o mlang $(OCAMLFLAGS) $(MAIN_OBJS)

.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly

.mll.ml:
	ocamllex $<
.mly.ml:
	ocamlyacc $<
.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

clean:
	rm -f mlang
	rm -f *~
	rm -f *.cm[iox]
	rm -f parser.ml parser.mli
	rm -f lexer.ml

parser.cmo : parser.cmi
parser.mli : parser.mly
parser.ml : parser.mly


.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml *.mly *.mll > .depend

include .depend