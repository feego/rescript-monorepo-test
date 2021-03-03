open Webapi

type rafId = rafId

let cancelRAFTimeout = cancelAnimationFrame

/**
 * Recursively calls requestAnimationFrame until a specified delay has been met or exceeded.
 * When the delay time has been reached the function you're timing out will be called.
 *
 * Credit: Joe Lambert (https://gist.github.com/joelambert/1002116#file-requesttimeout-js).
 */
let requestRAFTimeout = (callback: unit => unit, delay: float, updateRAFId: rafId => unit) => {
  let start = Js.Date.now()
  let rec timeout = _ => {
    let delta = Js.Date.now() -. start

    if delta >= delay {
      callback()
    } else {
      updateRAFId(requestCancellableAnimationFrame(timeout))
    }
  }

  requestAnimationFrame(timeout)
}
