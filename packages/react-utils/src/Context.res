module type Context = {
  type context
  let defaultValue: context
}

module Make = (Type: Context) => {
  open React;

  include Type
  let context: React.Context.t<Type.context> = createContext(Type.defaultValue)

  module Provider = {
    let provider: component<{
      "value": Type.context,
      "children": element,
    }> = React.Context.provider(context)

    @react.component
    let make = (~value: Type.context, ~children: element) => {
      createElement(provider, {"value": value, "children": children})
    }
  }
}
