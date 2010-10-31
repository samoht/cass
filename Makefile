FILES=\
cass.cmxa cass.cma \
cass_ast.mli cass_ast.cmi cass_ast.cmx \
cass_parser.mli cass_parser.cmi cass_parser.cmx \
cass_printer.mli cass_printer.cmi cass_printer.cmx \
cass_quotations.cmi cass_quotations.cmx \
cass_top.cmo \
css.cmx css.cmo css.cmi

BFILES=$(addprefix _build/,$(FILES))

STUFF=$(shell ocamlfind query cass -r -format "-I %d %a" -predicates byte)

all:
	ocamlbuild cass.cma cass_top.cmo cass.cmxa css.cmo css.cmx

install:
	ocamlfind install cass META $(BFILES)

uninstall:
	ocamlfind remove cass

clean:
	ocamlbuild -clean
	rm -rf test.exp test.cmo test.cmx test.cmi test.o

test:
	ocamlbuild test.byte
	./test.byte

test.exp: test.ml
	camlp4of _build/cass.cma test.ml -printer o > test.exp

debug: all
	camlp4of _build/cass.cma test.ml

