open React
open PackagesRescriptBindings
open DomAPI.Window

module Breakpoint = {
  type t = Width(int)
  let toString = (Width(value)) => {Belt.Int.toString(value) ++ "px"}
  let compare = Pervasives.compare
}

type context = {
  activeBreakpoint: Breakpoint.t,
  isServerValue: bool,
}

let defaultContextValue: context = {
  activeBreakpoint: Breakpoint.Width(0),
  isServerValue: true,
}

module Context = {
  let mediaContext = createContext(defaultContextValue)

  module Provider = {
    let provider = React.Context.provider(mediaContext)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

@react.component
let make = (~children, ~breakpoints: array<Breakpoint.t>) => {
  let (state, setState) = useState(() => defaultContextValue)
  let matchMediaQueries = useMemo1(() => {
    let window = getWindow()
    Belt.Option.mapWithDefault(window, [], window =>
      breakpoints
      ->Belt.SortArray.stableSortBy(Breakpoint.compare)
      ->Belt.Array.map(breakpoint => (
        breakpoint,
        Media.match(window, `(min-width: ${Breakpoint.toString(breakpoint)})`),
      ))
    )
  }, [breakpoints])
  let handleWindowResize: Media.listener = useCallback1(() => {
    let _ = Belt.Array.map(matchMediaQueries, ((breakpoint, query)) => {
      if query.matches {
        setState(_state => {activeBreakpoint: breakpoint, isServerValue: false})
      }
    })
  }, [matchMediaQueries])

  if Environment.isBrowser {
    useLayoutEffect1(() => {
      let _ = Belt.Array.map(matchMediaQueries, ((_breakpoint, query)) =>
        Media.addListener(query, handleWindowResize)
      )
      handleWindowResize()

      Some(
        () => {
          let _ = Belt.Array.map(matchMediaQueries, ((_breakpoint, query)) =>
            Media.removeListener(query, handleWindowResize)
          )
        },
      )
    }, [matchMediaQueries])
  }

  <Context.Provider value=state> children </Context.Provider>
}

let useMinWidthMediaQuery = () => useContext(Context.mediaContext)
