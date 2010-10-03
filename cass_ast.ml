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
  | String s  -> <:expr< Cass_ast.String $`str:s$ >>
  | Number f  -> <:expr< Cass_ast.Number $`flo:f$ >>
  | Dim (f,s) -> <:expr< Cass_ast.Dim ($`flo:f$, $`str:s$) >>

  | Percent f  -> <:expr< Cass_ast.Percent $`flo:f$ >>
  | Div (t1,t2) -> <:expr< Cass_ast.Div ($meta_t _loc t1$, $meta_t _loc t2$) >>

  | Colon      -> <:expr< Cass_ast.Colon >>
  | Prop (s,t) -> <:expr< Cass_ast.Prop ($`str:s$, $meta_t _loc t$) >>

  | Bracket t   -> <:expr< Cass_ast.Bracket $meta_t _loc t$ >>
  | Square t    -> <:expr< Cass_ast.Square $meta_t _loc t$ >>
  | Curly (n,t) -> <:expr< Cass_ast.Curly ($meta_t _loc n$, $meta_t _loc t$) >>

  | Semi (a,b)  -> <:expr< Cass_ast.Semi ($meta_t _loc a$, $meta_t _loc b$) >>
  | Comma (a,b) -> <:expr< Cass_ast.Comma ($meta_t _loc a$, $meta_t _loc b$) >>
  | Seq (a,b)   -> <:expr< Cass_ast.Seq ($meta_t _loc a$, $meta_t _loc b$) >> 
  | Nil         -> <:expr< Cass_ast.Nil >>

  | Ant (l, str) -> Ast.ExAnt (l, str)

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
