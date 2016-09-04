React = require 'react'
{ Grid, Row, Col } = require 'react-flexbox-grid'

{ Footer } = DashboardSection = require 'lab/DashboardSection'
CreateCreditCardForm = require 'lab/CreateCreditCardForm'
Button = require 'lab/Button'

module.exports = PaymentSection = ({ message }) ->

  <DashboardSection title='Payment Information'>
    {<PaymentSectionMessage {...message} />  if message}
    <CreateCreditCardForm />
    <Footer border>
      <Row style={{margin: '0'}} between='xs'>
        <Col>
          <Button size='small'>SAVE</Button>
          <Button size='small' type='link-secondary'>REMOVE CARD</Button>
        </Col>
        <Col>
          <Button size='small' type='link-primary-6'>PAYMENT HISTORY</Button>
        </Col>
      </Row>
    </Footer>
  </DashboardSection>


PaymentSectionMessage = ({ type, title, description }) ->

  IconComponent = if 'danger' is type then ErrorIcon else SuccessIcon

  <DashboardSection.Message
    IconComponent={IconComponent}
    type={type}
    title={title}
    description={description} />


ErrorIcon = ->

  one = require 'app/sprites/1x/cc-error.png'
  two = require 'app/sprites/2x/cc-error.png'

  imgOne = new Image
  imgOne.src = one
  { naturalHeight: height, naturalWidth: width } = imgOne

  src = if global.devicePixelRatio >= 2 then two else one

  <span><img src={src} style={{height, width}} /></span>


SuccessIcon = ->

  one = require 'app/sprites/1x/cc-error.png'
  two = require 'app/sprites/2x/cc-error.png'

  imgOne = new Image
  imgOne.src = one
  { naturalHeight: height, naturalWidth: width } = imgOne

  src = if global.devicePixelRatio >= 2 then two else one

  <span><img src={src} style={{height, width}} /></span>
