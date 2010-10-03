open Format
open Cass_ast

let rec t_ ppf = function
  | String s  -> fprintf ppf "%S" s
  | Number n  -> fprintf ppf "%g" n
  | Dim (f,d) -> fprintf ppf "%g%S" f d

  | Percent f    -> fprintf ppf "%g%%" f
  | Div (t1, t2) -> fprintf ppf "%a/@;<1 2>%a" t t1 t t2

  | Colon        -> fprintf ppf ":"
  | Prop (s, t') -> fprintf ppf "@[<h>%S@ :@ %a@]" s t t'

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

  | Ant (_, s) -> fprintf ppf "$%s$" s

and t ppf t = t_ ppf t (*t_of_list (list_of_t t [])*)

let to_string t' =
  t str_formatter t';
  flush_str_formatter ()
