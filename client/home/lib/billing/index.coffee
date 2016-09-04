React = require 'react'
kd = require 'kd'
ReactView = require 'app/react/reactview'

BillingPane = require './components/pane'

require './billing.styl'

module.exports = class HomeTeamBilling extends kd.CustomScrollView

  constructor: (options = {}, data) ->

    options.cssClass = kd.utils.curry 'HomeAppView--scroller', options.cssClass

    super options, data

    @wrapper.addSubView new BillingReactView


class BillingReactView extends ReactView

  constructor: (options = {}, data) ->

    options.cssClass = 'HomeAppView--pane'

    super options, data


  renderReact: ->

    <BillingPane />


