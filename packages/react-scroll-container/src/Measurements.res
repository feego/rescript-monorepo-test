open PackagesRescriptBindings

type scrollPosition = DomAPI.Measurements.scrollPosition

type boundingRect = DomAPI.Measurements.boundingRect

let initialScrollPosition: scrollPosition = {
  scrollTop: 0.,
  scrollLeft: 0.,
  scrollWidth: 0,
  scrollHeight: 0,
}

let initialBoundingRect: boundingRect = {
  top: 0.,
  right: 0.,
  bottom: 0.,
  left: 0.,
  width: 0.,
  height: 0.,
}
