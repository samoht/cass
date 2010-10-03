open Camlp4.PreCast (* for Ast refs in generated code *)

(*
  | Hash of string
  | Function of string * any
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

  | Ant of Loc.t * string

let rec meta_t _loc = function
  | String s  -> <:expr< Css.String $`str:s$ >>
  | Number f  -> <:expr< Css.Number $`flo:f$ >>
  | Dim (f,s) -> <:expr< Css.Dim ($`flo:f$, $`str:s$) >>

  | Percent f  -> <:expr< Css.Percent $`flo:f$ >>
  | Div (t1,t2) -> <:expr< Css.Div ($meta_t _loc t1$, $meta_t _loc t2$) >>

  | Colon      -> <:expr< Css.Colon >>
  | Prop (s,t) -> <:expr< Css.Prop ($`str:s$, $meta_t _loc t$) >>

  | Bracket t   -> <:expr< Css.Bracket $meta_t _loc t$ >>
  | Square t    -> <:expr< Css.Square $meta_t _loc t$ >>
  | Curly (n,t) -> <:expr< Css.Curly ($meta_t _loc n$, $meta_t _loc t$) >>

  | Semi (a,b)  -> <:expr< Css.Semi ($meta_t _loc a$, $meta_t _loc b$) >>
  | Comma (a,b) -> <:expr< Css.Comma ($meta_t _loc a$, $meta_t _loc b$) >>
  | Seq (a,b)   -> <:expr< Css.Seq ($meta_t _loc a$, $meta_t _loc b$) >> 
  | Nil         -> <:expr< Css.Nil >>

  | Ant (l, str) -> Ast.ExAnt (l, str)
