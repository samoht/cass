open Camlp4.PreCast
open Cass_ast

module Gram = MakeGram(Lexer)

let cass_eoi = Gram.Entry.mk "cass_eoi"

let parse_cass_eoi loc s = Gram.parse_string cass_eoi loc s

let debug = ref false

let debug (fmt: ('a , unit, string, unit) format4) =
	if !debug then
		Printf.kprintf (fun s -> print_string s) fmt
	else
		Printf.kprintf (fun s -> ()) fmt


EXTEND Gram
  GLOBAL: cass_eoi;

  str: [[
	  s = LIDENT    -> debug "LIDENT(%s) " s; s
	| s = UIDENT    -> debug "UIDENT(%s) " s; s
	| "-"; s = SELF -> debug "-(%s) " s; "-" ^ s
	| "#"; s = SELF -> debug "#(%s) " s; "#" ^ s
    | s1 = SELF; "-"; s2 = SELF -> debug "(%s-%s) " s1 s2; s1 ^ s2
    | s = STRING    -> debug "STRING(%S) " s; "\"" ^ s ^ "\""
  ]];

  number: [[
      i = INT   -> debug "INT(%s) " i; float_of_string i
    | f = FLOAT -> debug "FLOAT(%s) " f; float_of_string f
 ]];

  cass_seq: [[
      hd = cass ->  hd
    | hd = cass ; tl = SELF -> debug "SEQ "; Seq (hd, tl)
  ]];

  cass: [[
      s = str -> String s

    | n = number; "%"      -> debug "PERCENT(%g) " n; Percent n
    | s = number ; d = str -> debug "DIM(%g%s) " s d; Dim (s, d)
    | n = number           -> Number n

    | ":"                         -> debug "COLON "; Colon
    | s = str; ":" ; e = cass_seq -> debug "PROP "; Prop (s, e)
 
    | "["; es = SELF; "]" -> debug "SQUARE "; Square es
    | e1 = SELF; "{"; e2 = SELF; "}" -> debug "CURLY "; Curly (e1, e2)
    | "("; es = SELF; ")" -> debug "EXPR "; Bracket es

    | e1 = SELF; ";"; e2 = SELF -> debug "SEMI "; Semi (e1, e2)
    | e1 = SELF; ";"            -> debug "SEMI "; Semi (e1, Nil)
    | e1 = SELF; ","; e2 = SELF -> debug "COMMA "; Comma (e1, e2)

    | `ANTIQUOT (""|"int"|"flo"|"str"|"list"|"alist" as n, s) ->
        debug "ANTI(%s,%s) " n s; Ant (_loc, n ^ ":" ^ s)
  ]];

  cass_eoi: [[ x = cass; EOI -> debug "\n"; x ]];
END
