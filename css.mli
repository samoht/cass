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

(** Single element *)
type elt =
  | Str of string
  | Fun of string * expr list

(** Expression: `.body a:hover`. No commas here. *)
and expr = elt list

(** Property: `background-color: blue, red;` *)
type prop = string * expr list

(** Declarations: `contents, header { color: white; }` *)
type decl = expr list * prop list

(** The type of CSS fragment *)
type t =
  | Props of prop list
  | Decls of decl list
  | Exprs of expr list

val to_string : t -> string

(** {2 CSS library} *)

val gradient : low:t -> high:t -> t

val top_rounded : t
val bottom_rounded : t
val rounded: t

val box_shadow : t
val text_shadow : t

val no_padding : t
val reset_padding : t

