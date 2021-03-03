open ReactEvent

external castDomEvent: {..} => Dom.event = "%identity"

let getDomEvent: synthetic<'a> => Dom.event = event => {
  event->toSyntheticEvent->Synthetic.nativeEvent->castDomEvent
}
