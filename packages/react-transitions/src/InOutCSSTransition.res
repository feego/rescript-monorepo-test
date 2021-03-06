open React
open PackagesRescriptBindings

// // The animation only works when we force the setState to be asynchronous.
let tick = 17

type animationStates =
  | BeforeAppearing
  | Visible
  | Leaving

@react.component
let make = (
  ~children,
  ~timeout=300,
  ~_in,
  ~onEnter=?,
  ~onEntering=?,
  ~onExit=?,
  ~onExiting=?,
  ~onExited=?,
) => {
  let (animationState, setAnimationState) = useState(() => BeforeAppearing)
  let handleEnter = useCallback2(() => {
    let _timeoutID = Js.Global.setTimeout(() => setAnimationState(_state => Visible), tick)
    switch onEnter {
    | None => ()
    | Some(handler) => handler()
    }
  }, (setAnimationState, onEnter))
  let handleExit = useCallback2(() => {
    setAnimationState(_state => Leaving)
    switch onExit {
    | None => ()
    | Some(handler) => handler()
    }
  }, (setAnimationState, onExit))

  <ReactTransitionGroup.Transition
    _in timeout onEnter=handleEnter ?onEntering onExit=handleExit ?onExiting ?onExited>
    {children(animationState)}
  </ReactTransitionGroup.Transition>
}
