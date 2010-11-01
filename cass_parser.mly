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

%start main
%type <Cass_ast.t> main

%left COMMA
%left SEMI
%left OPEN
%left CLOSE
%left COLON
%left STRING
%left DOLLAR

%%

 one:
   | STRING { debug "STRING(%s)" $1; String $1 }
   | DOLLAR { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 comma:
   | one COMMA comma { debug "COMMA"; Comma ($1, $3) }
   | one             { $1 }
 ;

 seq:
   | one seq { debug "SEQ"; Seq ($1, $2) }
   | one     { $1 }
 ;

 seq_or_comma:
   | one COMMA comma  { debug "COMMA*"; Comma ($1, $3) }
   | one one seq      { debug "SEQ*";   Seq ($1, Seq($2, $3)) }
   | one one          { debug "SEQ+"; Seq ($1, $2) }
   | one              { $1 }
 ;

 rule:
   | one COLON seq_or_comma SEMI { debug "COLON"; Rule ($1, $3) }
   | DOLLAR SEMI                 { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 rules:
   | rule rules { debug "SEMI"; Semi($1, $2) }
   | rule       { $1 }
 ;

 decl:
   | one OPEN rules CLOSE { debug "COLON"; Decl ($1, $3) }
   | DOLLAR               { debug "DOLLAR(%s)" $1; Ant (Cass_location.get (), $1) }
 ;

 decls:
   | decl SEMI decls { debug "SEQ"; Seq ($1, $3) }
   | decl SEMI       { $1 }
 ;

 all:
   | rules        { $1 }
   | seq_or_comma { $1 }
   | decls        { $1 }
 ;

 main:
   | all EOF { debug "DECL"; newline (); $1 }
 ;

