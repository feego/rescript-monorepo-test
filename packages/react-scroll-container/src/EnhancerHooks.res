open React

type props<'element> = {
  lock: bool,
  noPointerEventsWhileScrolling: bool,
  useBodyScroller: bool,
  scrollingTimeout: int,
  innerRef: option<React.ref<Js.Nullable.t<'element>>>,
  children: element,
  className: option<string>,
  contentClassName: option<string>,
  style: option<ReactDOM.Style.t>,
  contentStyle: option<ReactDOM.Style.t>,
  passiveScrollEvent: bool,
  onClick: option<ReactEvent.Mouse.t => unit>,
  onScroll: option<Dom.event => unit>,
  onTouchStart: option<Dom.event => unit>,
  onTouchEnd: option<Dom.event => unit>,
  onScrollEnd: option<unit => unit>,
  getBoundingRect: option<unit => Measurements.boundingRect>,
  getScrollPosition: option<unit => Measurements.scrollPosition>,
  scrollTo: option<(float, float) => unit>,
  attachScrollListener: option<(Dom.event => unit) => unit>,
  detachScrollListener: option<(Dom.event => unit) => unit>,
  disablePointerEvents: option<unit => unit>,
  enablePointerEvents: option<unit => unit>,
}
