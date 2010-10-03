open Camlp4.PreCast

module Q = Syntax.Quotation
module AQ = Syntax.AntiquotSyntax

let destruct_aq s =
  let pos = String.index s ':' in
  let len = String.length s in
  let name = String.sub s 0 pos
  and code = String.sub s (pos + 1) (len - pos - 1) in
  name, code

let aq_expander =
object
  inherit Ast.map as super
  method expr =
    function
      | Ast.ExAnt (_loc, s) ->
          let n, c = destruct_aq s in
          let e = AQ.parse_expr _loc c in
          begin match n with
            | "int" -> <:expr< Cass_ast.Number (float_of_int $e$) >> (* e is an int *)
            | "flo" -> <:expr< Cass_ast.Numner $e$ >> (* e is a float *)
            | "str" -> <:expr< Cass_ast.String $e$ >> (* e is a string *)
            | "list" -> <:expr< Cass_ast.Comma.t_of_list $e$ >> 
            | "alist" -> <:expr< Cass_ast.Semi.t_of_list (List.map (fun (str,elt) -> Cass_ast.Colon (str, elt)) $e$) >> 
            | _ -> e
          end
      | e -> super#expr e
end

let parse_quot_string loc s =
  let q = !Camlp4_config.antiquotations in
  Camlp4_config.antiquotations := true;
  let res = Cass_parser.parse_cass_eoi loc s in
  Camlp4_config.antiquotations := q;
  res

let expand_expr loc _ s =
  let ast = parse_quot_string loc s in
  let meta_ast = Cass_ast.meta_t loc ast in
  aq_expander#expr meta_ast

let expand_str_item loc _ s =
  let exp_ast = expand_expr loc None s in
  <:str_item@loc< $exp:exp_ast$ >>

;;

Q.add "css" Q.DynAst.expr_tag expand_expr;
Q.add "css" Q.DynAst.str_item_tag expand_str_item;
Q.default := "css"
