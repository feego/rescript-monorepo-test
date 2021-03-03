open Belt
open React
open Webapi
open PackagesRescriptBindings
open Measurements

@get @return(nullable) external scrollX: Dom.Window.t => option<float> = "scrollX"
@get @return(nullable) external scrollY: Dom.Window.t => option<float> = "scrollY"

let useBodyScrollerController = (props: EnhancerHooks.props<'element>) => {
  /**
   * Stores the original pointer events value when it is disabled while scrolling.
   */
  let originalBodyPointerEvents = useRef("")

  /**
   * Calls the window.scroll method.
   */
  let scrollTo = useMemo0(() =>
    if Environment.isBrowser {
      (top, left) => Dom.Window.scroll(top, left, Dom.window)
    } else {
      (_top, _left) => ()
    }
  )

  /**
   * Returns an object with the window's current dimensions.
   */
  let getBoundingRect = useMemo0(() =>
    if Environment.isBrowser {
      open Dom

      (): boundingRect => {
        {
          top: 0.,
          right: 0.,
          bottom: 0.,
          left: 0.,
          width: Int.toFloat(Window.innerWidth(window)),
          height: Int.toFloat(Window.innerHeight(window)),
        }
      }
    } else {
      () => initialBoundingRect
    }
  )

  /**
   * Returns the document's scroll position data.
   */
  let getScrollPosition = useMemo0(() =>
    if Environment.isBrowser {
      open Dom
      let documentElement = Document.documentElement(document)

      (): scrollPosition => {
        scrollTop: Option.getWithDefault(scrollY(window), Element.scrollTop(documentElement)),
        scrollLeft: Option.getWithDefault(scrollX(window), Element.scrollLeft(documentElement)),
        scrollWidth: Element.scrollWidth(documentElement),
        scrollHeight: Element.scrollHeight(documentElement),
      }
    } else {
      () => initialScrollPosition
    }
  )

  /**
   * Disables the pointer events for the body of the current document.
   */
  let disablePointerEvents = () => {
    let body = DomAPI.Document.body(Dom.document)

    originalBodyPointerEvents.current =
      Dom.HtmlElement.style(body)->DomAPI.CssStyleDeclaration.pointerEvents
    // Dom.HtmlElement.setStyle(body, )
    // document.body.style.pointerEvents = 'none';
    ()
  }

  /**
   * Restores the pointer events for the body of the current document.
   */
  let enablePointerEvents = () => {
    // document.body.style.pointerEvents = originalBodyPointerEvents;
    ()
  }

  /**
   * Attaches a given scroll event handler to the current window.
   */
  let createAttachScrollListener = useCallback0((passive, scrollHandler) =>
    Dom.Window.addEventListenerWithOptions(
      "scroll",
      scrollHandler,
      {"passive": passive, "once": false, "capture": true},
      Dom.window,
    )
  )

  /**
   * Detaches a given scroll event handler from the current window.
   */
  let detachScrollListener = useCallback0(scrollHandler => {
    Dom.Window.removeEventListener("scroll", scrollHandler, Dom.window)
  })

  {
    ...props,
    scrollTo: Some(scrollTo),
    getBoundingRect: Some(getBoundingRect),
    getScrollPosition: Some(getScrollPosition),
    detachScrollListener: Some(detachScrollListener),
    disablePointerEvents: Some(disablePointerEvents),
    enablePointerEvents: Some(enablePointerEvents),
    attachScrollListener: Some(createAttachScrollListener(props.passiveScrollEvent)),
  }
}
