# - read given config file
# - find functions defined with the name starting with `on`
# - turn them into constant action types
# - create a reducer
# - bind handlers to the action types extracted from functions starting with `on`
# - read `types` prop of given config
#   - Arrays are async action definitions, in the form of [BEGIN, SUCCESS, FAIL]
#   - Strings are sync action definitions.
#   - generate action types combining it with `namespace` prop in config key.
#
# - namespaces
#   - is used to prefix action types
#   - each slash represents a sub namespace
#   - handler look up will be like this:
#
#     - module name: 'creditcard'
#     - namespace: 'koding/payment'
#     - onCustomerLoadSuccess: -> ...
#
#     - passed action type: 'koding/payment/customer/LOAD_SUCCESS'
#       - action info:
#       - namespace: koding/payment
#       - module: customer
#       - actionType: LOAD_SUCCESS
#
#     - look for: onCustomerLoadSuccess <- finds it, passes itself.
#     - look for: onPaymentCustomerLoadSuccess
#     - look for: onKodingPaymentCustomerLoadSuccess
#     - stops

createReduxModule = (config) ->

  actionHandlers = extractHandlers config

  reducer =

extractHandlers = flow(pickFunctions, pickHandlers)

pickFunctions = (config) -> pickBy(config, isFunction)

pickHandlers = (functions) -> pickBy(config, isActionHandler)

isActionHandler = (key) -> startsWith(key, 'on')

