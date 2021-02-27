open Belt

type styles

let css: array<option<string>> => option<string> = baseStyles => {
  let styles = Array.reduce(baseStyles, [], (styles, style) =>
    Option.mapWithDefault(style, styles, style => Array.concat(styles, [style]))
  )
  Js.log("asdss")
  Array.size(styles) > 0 ? Some(Css.merge(List.fromArray(styles))) : None
}

@module("@emotion/server")
external renderStylesToString: string => string = "renderStylesToString"

module Css = {
  include Css
  let style: array<Css.rule> => option<string> = rules => Some(Css.style(List.fromArray(rules)))
}

module React = {
  @module("@emotion/react") external css: string => styles = "css"

  module Global = {
    @module("@emotion/react") @react.component
    external make: (~children: option<React.element>=?, ~styles: styles) => React.element = "Global"
  }
}
