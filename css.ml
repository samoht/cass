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
  type elt =
    | Str of string
    | Fun of string * expr list

  and expr = elt list

  type prop = string * expr list

  type decl = expr list * prop list

  type t =
    | Props of prop list
    | Decls of decl list
    | Exprs of expr list

  open Format

  let rec elt ppf (e : elt) = match e with
    | Str s      -> fprintf ppf "%s" s
    | Fun (s,el) -> fprintf ppf "%s(%a)" s exprs el

  and expr ppf (e : expr) = match e with
    | []   -> ()
    | [h]  -> fprintf ppf "%a" elt h
    | h::t -> fprintf ppf "%a %a" elt h expr t

  and exprs ppf (el : expr list) = match el with
    | []   -> ()
    | [h]  -> fprintf ppf "%a" expr h
    | h::t -> fprintf ppf "%a, %a" expr h exprs t

  let prop ppf (n, el) =
    fprintf ppf "\t%s: %a;" n exprs el

  let rec props ppf (pl : prop list) = match pl with
    | []   -> ()
    | h::t -> fprintf ppf "%a\n%a" prop h props t

  let decl ppf (sl, pl) =
    fprintf ppf "%a {\n%a}\n" exprs sl props pl

  let rec decls ppf (dl : decl list) = match dl with
    | []   -> ()
    | h::t -> fprintf ppf "%a\n%a" decl h decls t

  let t ppf (x : t) = match x with
    | Props pl -> props ppf pl
    | Decls dl -> decls ppf dl
    | Exprs el -> exprs ppf el

  let to_string elt =
    t str_formatter elt;
    flush_str_formatter ()
end

(* From http://www.webdesignerwall.com/tutorials/cross-browser-css-gradient/ *)
let gradient ~low ~high =
  <:css<
    background: $low$; /* for non-css3 browsers */
    filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=$high$, endColorstr=$low$); /* for IE */
    background: -webkit-gradient(linear, left top, left bottom, from($high$), to($low$)); /* for webkit browsers */
    background: -moz-linear-gradient(top,  $high$,  $low$); /* for firefox 3.6+ */
 >>

let text_shadow =
  <:css<
    text-shadow: 0 1px 1px rgba(0,0,0,.3);  
  >>

let box_shadow =
  <:css<
    -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2);
    -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2);
    box-shadow: 0 1px 2px rgba(0,0,0,.2);
  >>

let rounded =
  <:css<
    -webkit-border-radius: .5em;
    -moz-border-radius: .5em;
    border-radius: .5em;
  >>

let top_rounded =
  <:css<
    -webkit-border-top-left-radius: .5em;
    -webkit-border-top-right-radius: .5em;
    -moz-border-radius-topleft: .5em;
    -moz-border-radius-topright: .5em;
    border-top-left-radius: .5em;
    border-top-right-radius: .5em;
  >>

let bottom_rounded =
  <:css<
    -webkit-border-bottom-left-radius: .5em;
    -webkit-border-bottom-right-radius: .5em;
    -moz-border-radius-bottomleft: .5em;
    -moz-border-radius-bottomright: .5em;
    border-bottom-left-radius: .5em;
    border-bottom-right-radius: .5em;
  >>

let no_padding =
  <:css<
    margin: 0;
    padding: 0;
  >>

let reset_padding =
  <:css<
    html, body, div,
    h1, h2, h3, h4, h5, h6,
    ul, ol, dl, li, dt, dd, p,
    blockquote, pre, form, fieldset,
    table, th, td { 
      margin: 0; 
      padding: 0; 
   }
  >>

include Css
