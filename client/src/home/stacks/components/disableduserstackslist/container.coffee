kd              = require 'kd'
React           = require 'kd-react'
EnvironmentFlux = require 'app/flux/environment'
KDReactorMixin  = require 'app/flux/base/reactormixin'
View            = require './view'
SidebarFlux = require 'app/flux/sidebar'


module.exports = class DisabledUserStacksListContainer extends React.Component

  getDataBindings: ->
    return {
      stacks: EnvironmentFlux.getters.disabledUsersStacks
      templates: EnvironmentFlux.getters.disabledUsersStackTemplates
      sidebarStacks: SidebarFlux.getters.sidebarStacks
    }


  onAddToSidebar: (stackId) -> SidebarFlux.actions.makeVisible 'stack', stackId


  onRemoveFromSidebar: (stackId) -> SidebarFlux.actions.makeHidden 'stack', stackId


  render: ->

    <View
      stacks={@state.stacks}
      templates={@state.templates}
      sidebarStacks={@state.sidebarStacks}
      onOpenItem={@props.onOpenItem}
      onAddToSidebar={@bound 'onAddToSidebar'}
      onRemoveFromSidebar={@bound 'onRemoveFromSidebar'}
    />

DisabledUserStacksListContainer.include [KDReactorMixin]


