(*
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
 *)

open Format
open Cass_ast

(* XXX: improve the formatter *)
let rec t_ ppf = function
  | String s  -> fprintf ppf "%S" s
  | Decl (s, t') -> fprintf ppf "%a { %a }" t s t t'
  | Rule (s, t') -> fprintf ppf "%a : %a" t s t t'
  | Semi (t', Nil) -> t ppf t'
  | Semi (t1, t2) -> fprintf ppf "%a;@;<1 2>%a" t t1 t t2
  | Comma (t', Nil) -> t ppf t'
  | Comma (t1, t2) -> fprintf ppf "%a,@;<1 2>%a" t t1 t t2
  | Seq (t', Nil) -> t ppf t'
  | Seq (t1, t2) -> fprintf ppf "%a @;<1 2>%a" t t1 t t2
  | Nil -> ()

  | Ant (_, s) -> fprintf ppf "$%s$" s

and t ppf t = t_ ppf t (*t_of_list (list_of_t t [])*)

let to_string t' =
  t str_formatter t';
  flush_str_formatter ()
