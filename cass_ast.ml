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

open Camlp4.PreCast (* for Ast refs in generated code *)

type t =
  | String of string
  | Decl of t * t
  | Rule of t * t
  | Semi of t * t
  | Comma of t * t
  | Seq of t * t
  | Nil

  | Ant of Loc.t * string

let rec meta_t _loc = function
  | String s    -> <:expr< Css.String $`str:s$ >>
  | Decl (s,t)  -> <:expr< Css.Decl ($meta_t _loc t$, $meta_t _loc t$) >>
  | Rule (s,t)  -> <:expr< Css.Rule ($meta_t _loc t$, $meta_t _loc t$) >>
  | Semi (a,b)  -> <:expr< Css.Semi ($meta_t _loc a$, $meta_t _loc b$) >>
  | Comma (a,b) -> <:expr< Css.Comma ($meta_t _loc a$, $meta_t _loc b$) >>
  | Seq (a,b)   -> <:expr< Css.Seq ($meta_t _loc a$, $meta_t _loc b$) >> 
  | Nil         -> <:expr< Css.Nil >>

  | Ant (l, str) -> Ast.ExAnt (l, str)
