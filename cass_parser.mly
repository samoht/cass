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

%token COMMA SEMI OPEN CLOSE EOF LEFT RIGHT EQ
%token <string> STRING DOLLAR PROP

%left EQ
%left COMMA
%left SEMI
%left OPEN CLOSE
%left LEFT RIGHT
%left DOLLAR
%left PROP
%left STRING


%start main
%type <Cass_ast.t> main

%%

 elt:
   | STRING EQ STRING        { debug "EQ";  ESeq(String $1, ESeq(String "=", String $3)) }
   | STRING EQ DOLLAR        { debug "EQ";  ESeq(String $1, ESeq(String "=", Ant (Cass_location.get (), $3))) }
   | STRING LEFT exprs RIGHT { debug "FUN"; Fun(String $1, $3) }
   | STRING                  { debug "STRING(%s)" $1; String $1 }
   | DOLLAR                  { debug "EDOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
;

 expr:
   | elt expr { debug "ESEQ"; ESeq ($1, $2) }
   | elt      { debug "ELT"; $1 }
;

 exprs:
   | expr COMMA exprs { debug "COMMA"; Comma ($1, $3) }
   | expr             { debug "ELTS"; $1 }
 ;

 prop:
   | PROP exprs SEMI         { debug "PROP(%s)" $1; Rule (String $1, $2) }
   | DOLLAR SEMI             { debug "RDOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
   | exprs OPEN props CLOSE  { debug "DECL"; Decl ($1, $3) }
   | DOLLAR                  { debug "DDOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 props:
   | prop props { debug "RSEQ"; RSeq ($1, $2) }
   | prop       { debug "PROP"; $1 }
 ;

 all:
   | exprs { $1 }
   | props { $1 }
 ;

 main:
   | all EOF { debug "DECL\n"; newline (); $1 }
 ;

