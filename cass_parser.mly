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

%token COMMA SEMI OPEN CLOSE EOF LEFT RIGHT
%token <string> STRING DOLLAR PROP

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

 args:
   | one COMMA args { Comma ($1, $3) }
   | one            { $1 }
 ;

 one:
   | STRING                 { debug "STRING(%s)" $1; String $1 }
   | DOLLAR                 { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 expr:
   | one LEFT args RIGHT { debug "FUN"; Fun ($1,$3) }
   | one                 { $1 }
 ;

 expr0:
   | expr expr0 { Seq ($1, $2) }
   | expr       { $1 }
 ;

 exprs:
   | expr0 COMMA exprs { debug "COMMA"; Comma ($1, $3) }
   | expr0             { $1 }
 ;

 rule:
   | PROP exprs SEMI { debug "COLON"; Rule (String $1, $2) }
   | DOLLAR SEMI     { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 rules:
   | rule rules         { debug "SEMI"; Seq($1, $2) }
   | rule               { $1 }
 ;

 decl:
   | exprs OPEN rules CLOSE  { debug "COLON"; Decl ($1, $3) }
   | DOLLAR                  { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 decls:
   | decl decls { debug "SEQ"; Seq ($1, $2) }
   | decl       { $1 }
 ;

 all:
   | decls { $1 }
   | rules { $1 }
   | exprs { $1 }
 ;

 main:
   | all EOF { debug "DECL"; newline (); $1 }
 ;

