type modalId = int

type rec modalRenderer = (~id: modalId, ~onClose: unit => unit) => React.element
and modal = {
  id: modalId,
  renderer: modalRenderer,
}

type modalsContext = {
  openedModals: array<modal>,
  openModal: modalRenderer => modal,
  closeModal: modal => unit,
}

include PackagesReactUtils.Context.Make({
  type context = modalsContext
  let defaultValue: context = {
    openedModals: [],
    openModal: _modal => {id: -1, renderer: (~id as _, ~onClose as _) => React.null},
    closeModal: _modal => (),
  }
})
