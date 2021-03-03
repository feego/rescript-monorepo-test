open Belt
open React

/**
 * Hook that enhances ScrollContainer's behavior disabling the pointer events in it while scrolling.
 */
let useNoPointerEventsWhileScrolling = (props: EnhancerHooks.props<'element>) => {
  let onScroll = useCallback2(event => {
    Option.forEach(props.disablePointerEvents, handler => handler())
    Option.forEach(props.onScroll, handler => handler(event))
  }, (props.disablePointerEvents, props.onScroll))
  let onScrollEnd = useCallback2(event => {
    Option.forEach(props.enablePointerEvents, handler => handler())
    Option.forEach(props.onScrollEnd, handler => handler(event))
  }, (props.enablePointerEvents, props.onScrollEnd))

  {
    ...props,
    onScroll: Some(onScroll),
    onScrollEnd: Some(onScrollEnd),
  }
}
