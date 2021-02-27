module Window = {
  type window

  @val external window: window = "window"
  let getWindow = () => Environment.isBrowser ? Some(window) : None

  module Media = {
    type listener = unit => unit
    type query = {
      matches: bool,
      media: string,
    }

    @bs.send external match: (window, string) => query = "matchMedia"
    @bs.send external addListener: (query, listener) => unit = "addListener"
    @bs.send external removeListener: (query, listener) => unit = "removeListener"
  }
}
