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
  | Decl of t * t
  | Rule of t * t
  | Fun of t * t
  | Comma of t * t
  | Seq of t * t
  | Nil

module Seq : sig
  val t_of_list : t list -> t
end

module Comma : sig
  val t_of_list : t list -> t
end

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

val interleave: string array -> t list -> t list
