open React

type handler = ReactEvent.Mouse.t => unit

module HandlerComparable = Belt.Id.MakeComparable({
  type t = handler
  let cmp = (handlerA, handlerB) => handlerA === handlerB ? 0 : -1
})

module Context = {
  type t = {
    subscribe: handler => unit,
    unsubscribe: handler => unit,
  }
  let context = createContext({subscribe: _handler => (), unsubscribe: _handler => ()})

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

@react.component
let make = (~children, ~className=?) => {
  let subscriptionsHandlersRef = useRef(Belt.Set.make(~id=module(HandlerComparable)))
  let subscribe = useCallback1((handler: handler) => {
    let _ = Belt.Set.add(subscriptionsHandlersRef.current, handler)
  }, [subscriptionsHandlersRef])
  let unsubscribe = useCallback1((handler: handler) => {
    let _ = Belt.Set.remove(subscriptionsHandlersRef.current, handler)
  }, [subscriptionsHandlersRef])
  let onClick = useCallback1(event => {
    ReactEvent.Mouse.stopPropagation(event)
    Belt.Set.forEach(subscriptionsHandlersRef.current, handler => handler(event))
  }, [subscriptionsHandlersRef])

  let contextAPI = useMemo2(
    (): Context.t => {subscribe: subscribe, unsubscribe: unsubscribe},
    (subscribe, unsubscribe),
  )

  <Context.Provider value={contextAPI}>
    <div ?className onClick role="presentation"> children </div>
  </Context.Provider>
}

let useGlobalClicksHandler = (handler, dependencies) => {
  let globalClicksHandlerAPI = useContext(Context.context)
  useEffect1(() => {
    globalClicksHandlerAPI.subscribe(handler)
    Some(() => globalClicksHandlerAPI.unsubscribe(handler))
  }, [dependencies])
}
