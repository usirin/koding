{ PropTypes } = React = require 'react'
{ Field } = require 'redux-form'

Input = require './Input'

module.exports = CreditCardInput = (props) ->

  { brand, fieldType } = props

  { placeholder, mask } = makeCardProps brand, fieldType
  props = _.omit props, ['brand', 'fieldType']

  <Input
    mask={mask}
    placeholder={placeholder}
    placeholderChar='•'
    {...props} />


templates =
  number:
    amex: ['••••', '••••••', '•••••']
    other: ['••••', '••••', '••••', '••••']

  cvc:
    amex: ['••••']
    other: ['•••']


makeCardProps = (brand, type = 'number') ->

  isAmex = brand is 'american-express'

  template = templates[type][if isAmex then 'amex' else 'other']

  mask = template
    .map (group) -> group.split('').map (char) -> /\d/
    .reduce (res, group, index) ->
      res = res.concat group
      if index is template.length - 1 then res else res.concat [' ']
    , []

  placeholder = template.join ' '

  return { mask, placeholder }


CreditCardInput.Field = (props) ->
  <Field {...props} component={InputForField} />

InputForField = (props) ->
  { input, meta, error } = props

  props = _.assign(
    # remove special props from props. This will result in the real props we
    # passed to the `Input.Field` component.
    _.omit(props, ['input', 'meta', 'error'])
    # merge it with input props.
    input
  )

  <CreditCardInput {...props} />



CreditCardInput.propTypes =
  brand: PropTypes.oneOf [
    'visa', 'master-card', 'american-express', 'diners-club'
    'discover', 'jcb', 'maestro'
  ]

CreditCardInput.defaultProps =
  brand: 'visa'

