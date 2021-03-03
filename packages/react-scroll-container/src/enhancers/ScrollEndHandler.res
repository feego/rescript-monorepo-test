open Belt

let useOnScrollEndHandler = (props: EnhancerHooks.props<'element>) => {
  let scrollingTimeoutIdRef: React.ref<option<RAFTimeout.rafId>> = React.useRef(None)

  /**
   * Restores the scroll container's pointer events.
   */
  let handleScrollEnd = React.useCallback2(() => {
    scrollingTimeoutIdRef.current = None
    Option.forEach(props.onScrollEnd, handler => handler())
  }, (scrollingTimeoutIdRef, props.onScrollEnd))

  /**
   * Clears an ongoing timeout, if one exists, triggered by a scroll event and registers a new one.
   */
  let refreshScrollingTimeoutId = React.useCallback3(() => {
    Option.forEach(scrollingTimeoutIdRef.current, RAFTimeout.cancelRAFTimeout)
    RAFTimeout.requestRAFTimeout(handleScrollEnd, Int.toFloat(props.scrollingTimeout), rafId =>
      scrollingTimeoutIdRef.current = Some(rafId)
    )
  }, (scrollingTimeoutIdRef, handleScrollEnd, props.scrollingTimeout))

  let handleScroll = React.useCallback2(event => {
    refreshScrollingTimeoutId()
    Option.forEach(props.onScroll, handler => handler(event))
  }, (refreshScrollingTimeoutId, props.onScroll))

  {...props, onScroll: Some(handleScroll)}
}
