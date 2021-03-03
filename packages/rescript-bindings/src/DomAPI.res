let getWindow = () => Environment.isBrowser ? Some(Webapi.Dom.window) : None
let getDocument = () => Environment.isBrowser ? Some(Webapi.Dom.document) : None

module Window = {
  open Webapi

  module Media = {
    type listener = unit => unit
    type query = {
      matches: bool,
      media: string,
    }

    @bs.send external match: (Dom.Window.t, string) => query = "matchMedia"
    @bs.send external addListener: (query, listener) => unit = "addListener"
    @bs.send external removeListener: (query, listener) => unit = "removeListener"
  }

  module Navigator = {
    type navigator = Dom.Window.navigator

    @get external platform: navigator => string = "platform"
  }
}

module Document = {
  open Webapi
  @get external body: Dom.Document.t => Dom.HtmlElement.t = "body"
}

module CssStyleDeclaration = {
  open Webapi
  @get external pointerEvents: Dom.CssStyleDeclaration.t => string = "pointerEvents"
}

module Types = {
  external webApiElementToJsObject: Webapi.Dom.Element.t => Js.t<'params> = "%identity"
  // external domElementToWebapiElement: Dom.element => Webapi.Dom.Element.t =
  //   "%identity";
}

module Measurements = {
  open Webapi.Dom

  type scrollPosition = {
    scrollTop: float,
    scrollLeft: float,
    scrollWidth: int,
    scrollHeight: int,
  }

  type boundingRect = {
    top: float,
    right: float,
    bottom: float,
    left: float,
    width: float,
    height: float,
  }

  let getScrollPosition = element => {
    scrollTop: Element.scrollTop(element),
    scrollLeft: Element.scrollLeft(element),
    scrollWidth: Element.scrollWidth(element),
    scrollHeight: Element.scrollHeight(element),
  }

  let getBoundingClientRect = element => {
    let domRect = Element.getBoundingClientRect(element)
    {
      top: DomRect.top(domRect),
      right: DomRect.right(domRect),
      bottom: DomRect.bottom(domRect),
      left: DomRect.left(domRect),
      width: DomRect.width(domRect),
      height: DomRect.height(domRect),
    }
  }
}

module Device = {
  /**
   * List of devices running iOS.
   */
  let iOSDevices = Belt.Set.String.fromArray([
    "iPad Simulator",
    "iPhone Simulator",
    "iPod Simulator",
    "iPad",
    "iPhone",
    "iPod",
  ])

  let isIOSDevice = () => {
    /**
     * Detects iOS devices.
     */
    if Environment.isBrowser {
      open Webapi

      let platform = Dom.Window.navigator(Dom.window)->Window.Navigator.platform
      Belt.Set.String.has(iOSDevices, platform)
    } else {
      false
    }
  }
}
