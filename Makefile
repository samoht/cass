FILES=\
cass.cmxa cass.cma \
cass_ast.mli cass_ast.cmi cass_ast.cmx \
cass_parser.mli cass_parser.cmi cass_parser.cmx \
cass_printer.mli cass_printer.cmi cass_printer.cmx \
cass_quotations.cmi cass_quotations.cmx \
cass_top.cmo \
css.cmx css.cmo css.cmi

BFILES=$(addprefix _build/,$(FILES))

INCLS = $(shell ocamlfind query dyntype.syntax -predicates syntax,preprocessor -r -format "-I %d %a") \

all:
	ocamlbuild cass.cma cass_top.cmo cass.cmxa
	ocamlbuild -pp "camlp4o $(INCLS) cass.cma" css.cmo css.cmx

install:
	ocamlfind install cass META $(BFILES)

uninstall:
	ocamlfind remove cass

clean:
	ocamlbuild -clean
	rm -rf test.exp test.cmo test.cmx test.cmi test.o

test:
	ocamlbuild -pp "camlp4o $(INCLS) cass.cma" test.byte --

.PHONY: text_exp
test_exp: test.ml $(BFILES)
	camlp4of $(INCLS) _build/cass.cma test.ml -printer o > test_exp.ml
	ocamlc -g -annot -I _build/ css.cmo test_exp.ml -o test_exp
	./test_exp

debug: all
	camlp4of _build/cass.cma test.ml

