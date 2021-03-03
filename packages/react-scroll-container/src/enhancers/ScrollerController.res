open Belt
open React
open Webapi
open PackagesReactUtils
open PackagesRescriptBindings
open PackagesRescriptBindings.Emotion.Css

let css = Emotion.css

module Styles = {
  let wrapper = style([
    overflow(#auto),
    /* Hints the browser to isolate the content in a new layer without creating a new stacking
     context. 'will-change: transform;' of other transform based hints would create new contexts. */
    unsafe("willChange", "opacity"),
    unsafe("WebkitOverflowScrolling", "touch"),
  ])
  let content = style([overflow(#auto)])
  let lockScroll = style([overflow(#hidden), unsafe("WebkitOverflowScrolling", "auto")])
}

let useScrollerController = (props: EnhancerHooks.props<'element>) => {
  let containerRef = Option.getWithDefault(props.innerRef, useRef(Js.Nullable.null))
  let (arePointerEventsEnabled, setArePointerEventsEnabled) = useState(() => true)

  /**
   * Returns an object with the dimensions of the wrapped scroll container.
   */
  let getBoundingRect = useCallback1(() => {
    Js.Nullable.toOption(containerRef.current)->Option.mapWithDefault(
      Measurements.initialBoundingRect,
      DomAPI.Measurements.getBoundingClientRect,
    )
  }, [containerRef])

  /**
   * Returns the scroll position data of the wrapped scroll container.
   */
  let getScrollPosition = useCallback1(() => {
    Js.Nullable.toOption(containerRef.current)->Option.mapWithDefault(
      Measurements.initialScrollPosition,
      DomAPI.Measurements.getScrollPosition,
    )
  }, [containerRef])

  /**
   * Scrolls the scroll container.
   */
  let scrollTo = useCallback1((top, left) => {
    Js.Nullable.iter(containerRef.current, (. element) => {
      Dom.Element.scrollTo(top, left, element)
    })
  }, [containerRef])

  /**
   * Disables the pointer events of the scroll container.
   */
  let disablePointerEvents = useCallback1(
    () => setArePointerEventsEnabled(_state => false),
    [setArePointerEventsEnabled],
  )

  /**
   * Restores the pointer events of the scroll container.
   */
  let enablePointerEvents = useCallback1(
    () => setArePointerEventsEnabled(_state => true),
    [setArePointerEventsEnabled],
  )

  /**
   * Attaches a given scroll event handler to the scroll container.
   */
  let attachScrollListener = useCallback1(scrollHandler => {
    Js.Nullable.iter(containerRef.current, (. element) => {
      Webapi.Dom.Element.addEventListenerWithOptions(
        "scroll",
        scrollHandler,
        {"passive": props.passiveScrollEvent, "once": false, "capture": false},
        element,
      )
    })
  }, [containerRef])

  /**
   * Unwrap React's SyntheticEvent into its respective Dom.event.
   */
  let onTouchStart = useMemo1(
    () =>
      Option.map(props.onTouchStart, (handler, event: ReactEvent.Touch.t) =>
        handler(Event.getDomEvent(event))
      ),
    [props.onTouchStart],
  )

  /**
   * Unwrap React's SyntheticEvent into its respective Dom.event.
   */
  let onTouchEnd = useMemo1(
    () =>
      Option.map(props.onTouchEnd, (handler, event: ReactEvent.Touch.t) =>
        handler(Event.getDomEvent(event))
      ),
    [props.onTouchEnd],
  )

  /**
   * Detaches a given scroll event handler from the scroll container.
   */
  let detachScrollListener = useCallback1(scrollHandler => {
    Js.Nullable.iter(containerRef.current, (. element) => {
      Webapi.Dom.Element.removeEventListener("scroll", scrollHandler, element)
    })
  }, [containerRef])

  let contentStyleValue = useMemo1(() => {
    let pointerEventsStyle = ReactDOM.Style.make(
      ~pointerEvents=?arePointerEventsEnabled ? None : Some("none"),
      (),
    )
    Option.mapWithDefault(props.style, pointerEventsStyle, style =>
      ReactDOM.Style.combine(style, pointerEventsStyle)
    )
  }, [arePointerEventsEnabled])

  {
    ...props,
    scrollTo: Some(scrollTo),
    getBoundingRect: Some(getBoundingRect),
    getScrollPosition: Some(getScrollPosition),
    attachScrollListener: Some(attachScrollListener),
    detachScrollListener: Some(detachScrollListener),
    disablePointerEvents: Some(disablePointerEvents),
    enablePointerEvents: Some(enablePointerEvents),
    children: <div
      ref={ReactDOM.Ref.domRef(containerRef)}
      className=?{css([Styles.wrapper, props.className, props.lock ? Styles.lockScroll : None])}
      style=?props.style
      onClick=?props.onClick
      ?onTouchStart
      ?onTouchEnd>
      <div className=?{css([Styles.content, props.contentClassName])} style={contentStyleValue}>
        props.children
      </div>
    </div>,
  }
}
