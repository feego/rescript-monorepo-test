open Belt

type styles

let css: array<option<string>> => option<string> = baseStyles => {
  let styles = Array.reduce(baseStyles, [], (styles, style) =>
    Option.mapWithDefault(style, styles, style => Array.concat(styles, [style]))
  )
  Array.size(styles) > 0 ? Some(Css.merge(List.fromArray(styles))) : None
}

@module("@emotion/server")
external renderStylesToString: string => string = "renderStylesToString"

module Css = {
  // Overload Css.Calc to add operations that do not use infix operators.
  module Calc = {
    include Css.Calc
    let subtract = (a, b) => #calc((#sub, a, b))
    let add = (a, b) => #calc((#add, a, b))
  }
  module MakeCss = (): (module type of Css with module Calc := Calc) => {
    include Css
  }
  include MakeCss()

  let style: array<Css.rule> => option<string> = rules => Some(Css.style(List.fromArray(rules)))
}

module React = {
  @module("@emotion/react") external css: string => styles = "css"

  module Global = {
    @module("@emotion/react") @react.component
    external make: (~children: option<React.element>=?, ~styles: styles) => React.element = "Global"
  }
}
