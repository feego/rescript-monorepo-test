open Belt
open React
open Measurements

type modalId = int

type scrollListener = Dom.event => unit

module ScrollListenerComparable = Id.MakeComparable({
  type t = scrollListener
  let cmp = (scrollListenerA, scrollListenerB) => scrollListenerA === scrollListenerB ? 0 : -1
})

type scrollerAPI = {
  registerScrollListener: scrollListener => unit,
  unregisterScrollListener: scrollListener => unit,
  getScrollPosition: unit => scrollPosition,
  getBoundingRect: unit => boundingRect,
  scrollTo: (float, float) => unit,
}

type scrollContext = {
  // Scroll container instances highest in the component tree set this flag to true,
  // which we then use to prevent the rubber band scroll animations in iOS.
  hasRootContainer: bool,
  closestScroller: scrollerAPI,
  rootScroller: scrollerAPI,
}

let defaultScrollerAPI = {
  registerScrollListener: _scrollListener => (),
  unregisterScrollListener: _scrollListener => (),
  getScrollPosition: () => initialScrollPosition,
  getBoundingRect: () => initialBoundingRect,
  scrollTo: (_top, _left) => (),
}

include PackagesReactUtils.Context.Make({
  type context = scrollContext
  let defaultValue: context = {
    // Scroll container instances highest in the component tree set this flag to true,
    // which we then use to prevent the rubber band scroll animations in iOS.
    hasRootContainer: false,
    closestScroller: defaultScrollerAPI,
    rootScroller: defaultScrollerAPI,
  }
})

let useScrollerAPI = (
  ~getScrollPosition=defaultScrollerAPI.getScrollPosition,
  ~getBoundingRect=defaultScrollerAPI.getBoundingRect,
  ~scrollTo=defaultScrollerAPI.scrollTo,
  (),
) => {
  let registeredScrollListenersRef = useRef(Set.make(~id=module(ScrollListenerComparable)))

  /**
   * Register a given component that wants to be notified when scroll events occur.
   */
  let registerScrollListener = useCallback1((scrollListener: scrollListener) => {
    let _ = Set.add(registeredScrollListenersRef.current, scrollListener)
  }, [registeredScrollListenersRef])

  /**
   * Unregisters a given component that no longer wants to be notified when scroll events occur.
   *
   * @param {Component} component - Component instance.
   *
   * @returns {undefined} Undefined.
   */
  let unregisterScrollListener = useCallback1((scrollListener: scrollListener) => {
    let _ = Set.remove(registeredScrollListenersRef.current, scrollListener)
  }, [registeredScrollListenersRef])

  /**
   * Calls the handlers of all registered scroll event listeners.
   */
  let notifySubscribedListeners = useCallback1(event => {
    Set.forEach(registeredScrollListenersRef.current, scrollListener => scrollListener(event))
  }, [registeredScrollListenersRef])

  /**
   * Builds the context API for interacting with this scroll container.
   */
  let scrollerAPI = useMemo5((): scrollerAPI => {
    registerScrollListener: registerScrollListener,
    unregisterScrollListener: unregisterScrollListener,
    getScrollPosition: getScrollPosition,
    getBoundingRect: getBoundingRect,
    scrollTo: scrollTo,
  }, (
    registerScrollListener,
    unregisterScrollListener,
    getScrollPosition,
    getBoundingRect,
    scrollTo,
  ))

  (scrollerAPI, notifySubscribedListeners)
}

@react.component
let make = (~scrollerAPI, ~children) => {
  let scrollContext = useContext(context)
  let scrollContextToPassDown = useMemo2(
    () =>
      scrollContext.hasRootContainer
        ? {...scrollContext, closestScroller: scrollerAPI}
        : {hasRootContainer: true, closestScroller: scrollerAPI, rootScroller: scrollerAPI},
    (scrollerAPI, scrollContext.hasRootContainer),
  )

  <Provider value={scrollContextToPassDown}> {children} </Provider>
}
