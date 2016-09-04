_ = require 'lodash'
{ PropTypes } = React = require 'react'
classNames = require 'classnames'
{ MaskedInput } = require 'react-text-mask'
{ Field } = require 'redux-form'

styles = require './Input.stylus'

module.exports = Input = (props) ->

  { className, size, disabled, type, auto, title, mask, name } = props

  className = classNames [
    className
    styles['Input']
    styles[size]
    disabled and styles.disabled
    auto and styles.auto
    mask and styles.masked
  ]

  props = _.omit props, ['size', 'auto', 'title']

  props = _.assign {}, props, { type, className }

  Component = if props.mask then MaskedInput else 'input'

  console.log {type}

  <div className={styles.wrapper}>
    {<label className={styles.title} htmlFor={props.name}>{title}</label>  if title}
    <MaskedInput {...props} />
  </div>

Input.Field = (props) ->
  console.log Object.keys props
  <Field {...props} component={InputForField} />


InputForField = (props) ->
  console.log {props}
  { input, meta, error } = props

  props = _.assign(
    # remove special props from props. This will result in the real props we
    # passed to the `Input.Field` component.
    _.omit(props, ['input', 'meta', 'error'])
    # merge it with input props.
    input
  )

  <Input {...props} />


Input.propTypes =
  size: PropTypes.oneOf [
    'small', 'medium', 'large'
  ]
  type: PropTypes.string
  auto: PropTypes.bool
  disabled: PropTypes.bool


Input.defaultProps =
  size: 'medium'
  type: 'text'
  auto: on
  disabled: off

