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

module Css = struct
  type t =
    | String of string
    | Decl of t * t
    | Rule of t * t
    | Fun of t * t
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

  (* XXX: fix the formatter *)
  let rec t ppf = function
    | String s       -> fprintf ppf "%s" s
    | Decl (t1, t2)  -> fprintf ppf "%a {\n%a}\n" t t1 t t2
    | Rule (t1, t2)  -> fprintf ppf "\t%a: %a;\n" t t1 t t2
    | Fun (t1, t2)   -> fprintf ppf "%a(%a)" t t1 t t2

    | Comma (t1, Nil) -> t ppf t1
    | Comma (t1, t2)  -> fprintf ppf "%a, %a" t t1 t t2

    | Seq (t1, Nil)   -> t ppf t1
    | Seq (t1, t2)    -> fprintf ppf "%a %a" t t1 t t2

    | Nil -> ()

  let to_string t1 =
    t str_formatter t1;
    flush_str_formatter ()
end

open Css

(* From http://www.webdesignerwall.com/tutorials/cross-browser-css-gradient/ *)
let gradient ~low ~high =
  <:css<
    background: $low$; /* for non-css3 browsers */
    filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=$high$, endColorstr=$low$); /* for IE */
    background: -webkit-gradient(linear, left top, left bottom, from($high$), to($low$)); /* for webkit browsers */
    background: -moz-linear-gradient(top,  $high$,  $low$); /* for firefox 3.6+ */
 >>

let rounded : t =
  <:css<
    text-shadow: 0 1px 1px rgba(0,0,0,.3);
    -webkit-border-radius: .5em;
    -moz-border-radius: .5em;
    border-radius: .5em;
    -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2);
    -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2);
    box-shadow: 0 1px 2px rgba(0,0,0,.2);
  >>
                                                               
include Css
