open Belt
open React
open PackagesRescriptBindings

@react.component
let make = (
  ~lock=false,
  ~useBodyScroller=false,
  ~noPointerEventsWhileScrolling=false,
  ~scrollingTimeout=100,
  ~innerRef=?,
  ~children,
  ~className=?,
  ~contentClassName=?,
  ~style=?,
  ~contentStyle=?,
  ~onClick=?,
  ~onScroll=?,
  ~onTouchStart=?,
  ~onTouchEnd=Some((_event) => ()),
  ~onScrollEnd=?,
) => {
  let propsForHooks: EnhancerHooks.props<'element> = {
    lock: lock,
    useBodyScroller: useBodyScroller,
    noPointerEventsWhileScrolling: noPointerEventsWhileScrolling,
    scrollingTimeout: scrollingTimeout,
    innerRef: innerRef,
    children: children,
    className: className,
    contentClassName: contentClassName,
    style: style,
    contentStyle: contentStyle,
    onClick: onClick,
    onScroll: onScroll,
    getBoundingRect: None,
    getScrollPosition: None,
    passiveScrollEvent: true,
    onTouchStart: onTouchStart,
    onTouchEnd: onTouchEnd,
    onScrollEnd: onScrollEnd,
    scrollTo: None,
    attachScrollListener: None,
    detachScrollListener: None,
    disablePointerEvents: None,
    enablePointerEvents: None,
  }
  let scrollContext = useContext(ScrollContext.context)
  let needsIOSHackery = useMemo1(
    () => DomAPI.Device.isIOSDevice() && !scrollContext.hasRootContainer,
    [scrollContext.hasRootContainer],
  )
  let useEnhancerHooks = useMemo0(() => {
    propsForHooks => {
      let identity = props => props
      let hooks = [
        needsIOSHackery ? IOSHackery.useIOSHackery : identity,
        useBodyScroller ? BodyScrollerController.useBodyScrollerController : ScrollerController.useScrollerController,
        noPointerEventsWhileScrolling ? PointerEventsController.useNoPointerEventsWhileScrolling : identity,
        props => Option.isSome(props.onScroll) ? ScrollEndHandler.useOnScrollEndHandler(props) : props
      ]
      Array.reduce(hooks, propsForHooks, (currentPropsForHooks, useHook) =>
        useHook(currentPropsForHooks)
      )
    }
  })
  let enhancedProps = useEnhancerHooks(propsForHooks)
  let (scrollerAPI, notifySubscribedListeners) = ScrollContext.useScrollerAPI(
    ~getScrollPosition=?enhancedProps.getScrollPosition,
    ~getBoundingRect=?enhancedProps.getBoundingRect,
    ~scrollTo=?enhancedProps.scrollTo,
    (),
  )

  /**
   * Notifies all scroll event listeners for a scroll event and disables the pointer events for the scroll container
   * for better performance.
   */
  let handleScroll = useCallback2(event => {
    notifySubscribedListeners(event)
    Option.forEach(enhancedProps.onScroll, handler => handler(event))
  }, (notifySubscribedListeners, enhancedProps.onScroll))

  useEffect0(() => {
    Option.forEach(enhancedProps.attachScrollListener, attach => attach(handleScroll))
    Some(
      () => {
        Option.forEach(enhancedProps.detachScrollListener, dettach => dettach(handleScroll))
      },
    )
  })

  <ScrollContext scrollerAPI> {enhancedProps.children} </ScrollContext>
}
