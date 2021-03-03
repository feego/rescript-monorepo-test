open Belt
open React
open PackagesRescriptBindings
let css = Emotion.css

module Styles = {
  open Emotion.Css

  let iOSScrollFix = style([flex3(~grow=1., ~shrink=0., ~basis=Calc.add(pct(100.), px(2)))])
}

/**
 * Scrolls a given DOM element up or down one pixel if the scroll position has reached the limits, so that the same element
 * will trigger the rubber band scrolling effects when the user scrolls it after its limits after that. This way, we prevent
 * the document's body to trigger that effects, so the user doesn't have to wait for the animation to finish to keep scrolling
 * in the scroll container.
 *
 * @see http://blog.christoffer.online/2015-06-10-six-things-i-learnt-about-ios-rubberband-overflow-scrolling/
 */
let scrollElementIfOnLimit = (element: Webapi.Dom.Element.t) => {
  open Webapi.Dom
  let top = Element.scrollTop(element)

  if top <= 0. {
    Element.setScrollTop(element, 1.)
  } else {
    switch Element.asHtmlElement(element) {
    | None => ()
    | Some(htmlElement) =>
      if (
        Belt.Int.fromFloat(top) >=
        Element.scrollHeight(element) - HtmlElement.offsetHeight(htmlElement)
      ) {
        Element.setScrollTop(element, top -. 1.)
      }
    }
  }
}

/**
 * Hook that prevents the rubber band scrolling effect from happening in the document's body, when we use
 * other DOM element as the root scroll container.
 */
let useIOSHackery = (props: EnhancerHooks.props<'element>) => {
  let containerRef = Option.getWithDefault(props.innerRef, useRef(Js.Nullable.null))
  let didTouchEndRef = useRef(true)

  let scrollIfOnLimit = useCallback0(() => {
    Js.Nullable.iter(containerRef.current, (. element) => {scrollElementIfOnLimit(element)})
  })

  /**
   * Adds a scrolling behaviour that prevents the page body from scrolling.
   */
  let handleTouchStart = useCallback2((event: Dom.event) => {
    scrollIfOnLimit()

    if didTouchEndRef.current {
      didTouchEndRef.current = false
    }

    Option.forEach(props.onTouchStart, handler => handler(event))
  }, (scrollIfOnLimit, props.onTouchStart))

  let handleTouchEnd = useCallback1((event: Dom.event) => {
    didTouchEndRef.current = true
    Option.forEach(props.onTouchEnd, handler => handler(event))
  }, [props.onTouchEnd])

  let handleScrollEnd = useCallback2(event => {
    if didTouchEndRef.current {
      scrollIfOnLimit()
    }
    Option.forEach(props.onScrollEnd, handler => handler(event))
  }, (scrollIfOnLimit, props.onScrollEnd))

  let attachTouchEventListeners = useCallback2(() => {
    Js.Nullable.iter(containerRef.current, (. element) => {
      Webapi.Dom.Element.addEventListenerWithOptions(
        "touchstart",
        handleTouchStart,
        {"passive": false, "once": false, "capture": true},
        element,
      )
      Webapi.Dom.Element.addEventListenerWithOptions(
        "touchend",
        handleTouchStart,
        {"passive": false, "once": false, "capture": true},
        element,
      )
    })
  }, (handleTouchStart, handleTouchEnd))

  let detachTouchEventListeners = useCallback2(() => {
    Js.Nullable.iter(containerRef.current, (. element) => {
      Webapi.Dom.Element.removeEventListener("touchstart", handleTouchStart, element)
      Webapi.Dom.Element.removeEventListener("touchend", handleTouchStart, element)
    })
  }, (handleTouchStart, handleTouchEnd))

  useEffect0(() => {
    let _ = Js.Global.setTimeout(scrollIfOnLimit, 0)
    attachTouchEventListeners()
    Some(detachTouchEventListeners)
  })

  {
    ...props,
    innerRef: Some(containerRef),
    scrollingTimeout: 66,
    passiveScrollEvent: false,
    contentClassName: css([Styles.iOSScrollFix, props.contentClassName]),
    onScrollEnd: Some(handleScrollEnd),
    onTouchStart: None,
    onTouchEnd: None,
  }
}
