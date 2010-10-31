/*
 * Copyright (c) 2010 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

%{
  open Cass_ast

  let debug = ref false

  let parse_error str =
    Camlp4.PreCast.Loc.raise (Cass_location.get ()) Parse_error

  let newline () =
    if !debug then
      Printf.eprintf "\n"

  let debug (fmt: ('a , unit, string, unit) format4) =
    if !debug then
      Printf.kprintf (fun s -> Printf.eprintf "[%s] %!" (String.escaped s)) fmt
    else
      Printf.kprintf (fun s -> ()) fmt
%}

%token COMMA SEMI OPEN CLOSE COLON EOF
%token <string> STRING DOLLAR

%start decl_list rule_list elt_seq elt_list elt
%type <Cass_ast.t> decl_list rule_list elt_seq elt_list elt

%left COMMA
%left SEMI
%left OPEN CLOSE
%left COLON
%left STRING DOLLAR

%%

elt:
   | STRING { debug "STRING(%s)" $1; String $1 }
   | DOLLAR { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }

elt_list:
   | elt COMMA elt_list { debug "COMMA"; Comma ($1, $3) }
   | elt elt_list       { debug "lSEQ"; Seq ($1, $2) }
   | elt                { $1 }
;

elt_seq:
   | elt elt_seq { debug "SEQ"; Seq ($1, $2) }
   | elt         { $1 }
;

rule:
   | elt COLON elt_list { debug "COLON"; Rule ($1, $3) }
   | DOLLAR             { debug "rDOLLAR"; Ant (Cass_location.get (), $1) }
;

rule_list:
   | rule SEMI rule_list { debug "RULE;..."; Semi ($1, $3) }
   | rule SEMI           { debug "RULE;"; $1 }
;

decl:
   | elt_seq OPEN rule_list CLOSE { debug "... { ... }"; Decl ($1, $3) }
;

decl_list:
   | decl EOF       { debug "DECL"; newline (); $1 }
   | decl decl_list { Seq ($1, $2) }
;

