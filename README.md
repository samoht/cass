A CSS quotation mechanism for ocaml using camlp4.

This library started as a toy-project at very good
[CUFP tutorial](http://cufp.org/conference/sessions/2010/camlp4-and-template-haskell)
by [Jake Donham](http://www.github.com/jaked) and [Nicolas Pouillard](http://www.github.com/np).
It is now in a working state for bigger projects.

Examples
--------

Define two global CSS colors:

    let color1 = <:css< black >>
    let color2 = <:css< gray >>

Define the style for a button; we can a specific API to generate cross-platform complex styles.

    let button = <:css< 
       .button {
         $Css.gradient ~low:color2 ~high:color1$;
         color: white;
         $Css.top_rounded$;
     >>

We can the use nested declarations to build modular styles :

    let container button_style header_style = <:css<
       .container {
         $button_style$;
         $header_style$;
         background-color: green;
        }

    let mystyle = container button <:css< h1 { font-weight: bold; } >>

Remarks
-------

The parser is far for being perfect. For example, to write properties do not forget to add a space
character after the colon (ie. `foo: bar`, not `foo:bar`)
	
		
