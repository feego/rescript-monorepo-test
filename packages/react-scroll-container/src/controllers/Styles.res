open PackagesRescriptBindings.Emotion.Css

let wrapper = style([
  /* Hints the browser to isolate the content in a new layer without creating a new stacking
   context. 'will-change: transform;' of other transform based hints would create new contexts. */
  unsafe("will-change", "opacity"),
  overflow(#auto),
  unsafe("-webkitOverflowScrolling", "touch"),
])
let content = style([overflow(#auto)])
let lockScroll = style([overflow(#hidden), unsafe("-webkitOverflowScrolling", "auto")])
