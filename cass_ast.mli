open Camlp4.PreCast

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

val meta_t : Ast.loc -> t -> Ast.expr
