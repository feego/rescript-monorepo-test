module Breakpoints = {
  open MediaContextProvider
  let smallPhone: MediaContextProvider.Breakpoint.t = Breakpoint.Width(0)
  let phone: MediaContextProvider.Breakpoint.t = Breakpoint.Width(375)
  let phoneLandscape: MediaContextProvider.Breakpoint.t = Breakpoint.Width(576)
  let tabletPortrait: MediaContextProvider.Breakpoint.t = Breakpoint.Width(768)
  let tabletLandscape: MediaContextProvider.Breakpoint.t = Breakpoint.Width(1024)
  let desktop: MediaContextProvider.Breakpoint.t = Breakpoint.Width(1200)
  let asArray = [smallPhone, phone, phoneLandscape, tabletPortrait, tabletLandscape, desktop]
}
