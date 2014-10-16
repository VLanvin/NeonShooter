default:
	ocamlbuild -I src -use-ocamlfind -package "ocsfml.graphics ocsfml.audio" main.native

profiling:
	ocamlbuild -cflags -g -I src -use-ocamlfind -package "ocsfml.graphics ocsfml.audio" main.p.native

byte:
	ocamlbuild -I src -use-ocamlfind -package "ocsfml.graphics ocsfml.audio" main.byte

clean:
	ocamlbuild -clean
