let color1 = <:css< #fff >>;;
let color2 = <:css< #e3e3e3 >>;;

let props = <:css<
  background: $expr:[color1; color2]$;
  border-top: 15px solid $color2$;
>>;;

let c2 = <:css<
body { $props$;
        font: "helvetica neue", "helvetica", "arial", sans-serif;
        $Css.gradient ~low:color1 ~high:color2$;
        $Css.rounded$;

        h1 { font-weight: bold; }
     }
>>

let s = Css.to_string c2

let _ = Printf.printf "%s\n%!" s 
