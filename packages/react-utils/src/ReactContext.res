open React

module type Context = {
  type context
  let defaultValue: context
}

module Context = (Type: Context) => {
  include Type
  let context: Context.t<Type.context> = createContext(Type.defaultValue)

  module Provider = {
    let provider: component<{
      "value": Type.context,
      "children": element,
    }> = Context.provider(context)

    @react.component
    let make = (~value: Type.context, ~children: element) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
