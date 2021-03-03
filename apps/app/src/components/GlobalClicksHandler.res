open React

type handler = ReactEvent.Mouse.t => unit

module HandlerComparable = Belt.Id.MakeComparable({
  type t = handler
  let cmp = (handlerA, handlerB) => handlerA === handlerB ? 0 : -1
})

type globalClicksContext = {
  subscribe: handler => unit,
  unsubscribe: handler => unit,
}

module Context = PackagesReactUtils.Context.Make({
  type context = globalClicksContext
  let defaultValue: context = {subscribe: _handler => (), unsubscribe: _handler => ()}
})

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
    (): globalClicksContext => {subscribe: subscribe, unsubscribe: unsubscribe},
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
