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

type t =
  | String of string
  | Number of float
  | Dim of float * string

  | Percent of float
  | Div of t * t

  | Colon
  | Prop of string * t

  | Bracket of t
  | Square of t
  | Curly of t * t

  | Semi of t * t
  | Comma of t * t
  | Seq of t * t
  | Nil

module Comma = struct
  let rec t_of_list = function
    | [] -> Nil
    | [e] -> e
    | e::es -> Comma (e, t_of_list es)

  let rec list_of_t x acc =
    match x with
    | Nil -> acc
    | Comma (e1, e2) -> list_of_t e1 (list_of_t e2 acc)
    | e -> e :: acc
end

module Semi = struct
  let rec t_of_list = function
    | [] -> Nil
    | [e] -> e
    | e::es -> Semi (e, t_of_list es)

  let rec list_of_t x acc =
    match x with
    | Nil -> acc
    | Semi (e1, e2) -> list_of_t e1 (list_of_t e2 acc)
    | e -> e :: acc
end

module Seq = struct
  let rec t_of_list = function
    | [] -> Nil
    | [e] -> e
    | e::es -> Seq (e, t_of_list es)

  let rec list_of_t x acc =
    match x with
    | Nil -> acc
    | Seq (e1, e2) -> list_of_t e1 (list_of_t e2 acc)
    | e -> e :: acc
end

open Printf
open Format

let rec t ppf = function
  | String s  -> fprintf ppf "%s" s
  | Number n  -> fprintf ppf "%g" n
  | Dim (f,d) -> fprintf ppf "%g%s" f d

  | Percent f    -> fprintf ppf "%g%%" f
  | Div (t1, t2) -> fprintf ppf "%a/@;<1 2>%a" t t1 t t2

  | Colon        -> fprintf ppf ":"
  | Prop (s, t') -> fprintf ppf "@[<h>%s@ :@ %a@]" s t t'

  | Bracket t'     -> fprintf ppf "@[<hv>(@;<1 2>%a@ )@]" t t'
  | Square t'      -> fprintf ppf "@[<hv>[@;<1 2>%a@ ]@]" t t'
  | Curly (t1, t2) -> fprintf ppf "%a @[<hv>{@;<1 2>%a@ }@]" t t1 t t2

  | Semi (t', Nil) -> t ppf t'
  | Semi (t1, t2) -> fprintf ppf "%a;@;<1 2>%a" t t1 t t2

  | Comma (t', Nil) -> t ppf t'
  | Comma (t1, t2) -> fprintf ppf "%a,@;<1 2>%a" t t1 t t2

  | Seq (t', Nil) -> t ppf t'
  | Seq (t1, t2) -> fprintf ppf "%a @;<1 2>%a" t t1 t t2

  | Nil -> ()

let to_string t' =
  t str_formatter t';
  flush_str_formatter ()

