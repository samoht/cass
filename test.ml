let color1 = <:css< #fff >>;;
let color2 = <:css< #e3e3e3 >>;;

let props = <:css<
  background: $list:[color1; color2]$;
  border-top: 15px solid $color2$;
>>;;

let c2 = <:css<
body { $props$;
        font: 62.5% "helvetica neue", "helvetica", "arial", sans-serif;
}
>>

let s = Css.to_string c2

let _ = Printf.printf "%s\n%!" s 

(*
let broken = <:css< >>
*)
