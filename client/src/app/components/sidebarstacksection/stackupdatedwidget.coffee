kd = require 'kd'
React         = require 'kd-react'
actions       = require 'app/flux/environment/actions'
SidebarWidget = require 'app/components/sidebarmachineslistitem/sidebarwidget'


module.exports = class StackUpdatedWidget extends React.Component

  @defaultProps =
    className   : 'StackUpdated'


  constructor: ->

    @state    =
      isShown : no


  componentWillReceiveProps: (nextProps) ->

    @setState { isShown : not nextProps.show }


  handleOnClick : ->
    { appManager, router } = kd.singletons
    templateId =  @props.stack.get 'baseStackId'
    actions.reinitStackFromWidget(@props.stack).then ->
      appManager.tell 'Stackeditor', 'reloadEditor', templateId


  handleOnClose: ->

    @setState { isShown : yes }


  render: ->

    return null  if @state.isShown

    <SidebarWidget {...@props} onClose={@bound 'handleOnClose'}>
      <span>STACK UPDATED</span>
      <p className='SidebarWidget-Title'>You need to reinitialize your machines before booting.</p>
      <button className='kdbutton solid medium green reinit-stack' onClick={@bound 'handleOnClick'}>
        <span className='button-title'>UPDATE MY MACHINES</span>
      </button>
    </SidebarWidget>
