let color1 = <:css< #fff >>;;
let color2 = <:css< #e3e3e3 >>;;

let props = <:css<
  background: $list:[color1; color2]$;
  border-top: 15px solid $color2$;
>>;;

let c2 = <:css<
body { $props$;
        font: "helvetica neue", "helvetica", "arial", sans-serif;
        $Css.gradient color1 color1 color2$;
}
>>

let s = Css.to_string c2

let _ = Printf.printf "%s\n%!" s 
