
module.exports = class CreditCard extends ReduxModule

  @namespace = 'koding/payment/creditcard'

  @asyncTypes = ['REMOVE']

  onRemove


createReduxModule({

  namespace: 'koding/payment'

  types:
    SET: 'SET'
    REMOVE: ['BEGIN', 'SUCCESS', 'FAIL']

  provide:
    remove: ({ payment }) -> payment.deleteCreditCard()

  onCustomerLoadSuccess: customerLoadSuccess
  onCustomerCreateSuccess: customerLoadSuccess
  onCustomerUpdateSuccess: customerLoadSuccess

  onInfoLoadSuccess: infoLoadSuccess

  onRemoveSuccess: removeSuccess
  onCustomerRemoveSuccess: removeSuccess

})

createReduxModule = (config) ->
  { register, provide, types, namespace } = config

  reducer = (state, action) ->
    unless action.type in register
      return state

    actionHandlers = register.map (actionType) ->
      [..., moduleName, actionName] = actionType.split '/'

      actionName = actionName.split('_').map(_.capitalize).join('')

      return "on#{_.capitalize moduleName}#{actionName}"

    actionHandlers = actionHandlers.concat types.reduce (result, type) ->
      if Array.isArray type


