kd = require 'kd'
PageContainer = require '../views/pagecontainer'
StackFlowController = require './stackflowcontroller'
MachineFlowController = require './machineflowcontroller'
NoStackPageView = require '../views/nostackpageview'
environmentDataProvider = require 'app/userenvironmentdataprovider'

module.exports = class ResourceStateController extends kd.Controller

  constructor: (options, data) ->

    super options, data

    @createPageContainer()
    @createInitialView()


  loadData: ->

    machine = @getData()
    return  unless machine

    { computeController } = kd.singletons
    computeController.ready =>
      machineId = machine.jMachine._id
      stack     = computeController.findStackFromMachineId machineId
      return kd.log 'ResourceStateController: stack not found!'  unless stack

      @setup stack
      @currentFlow.loadData()


  createPageContainer: ->

    { container } = @getOptions()

    container.addSubView @pageContainer = new PageContainer()
    @forwardEvent @pageContainer, 'PaneDidShow'


  createInitialView: ->

    machine = @getData()
    if machine
      view = new kd.CustomHTMLView
        cssClass : 'loader-container'
        partial  : "<div class='loader-text'>Loading...</div>"
      view.addSubView new kd.LoaderView
        showLoader : yes
        size       :
          width    : 40
          height   : 40
    else
      view = new NoStackPageView()

    @pageContainer.appendPages view
    @pageContainer.showPage view


  setup: (stack) ->

    machine     = @getData()
    { initial } = @getOptions()

    if stack.status?.state isnt 'Initialized'
      @currentFlow = new StackFlowController {
        container : @pageContainer
      }, { machine, stack }
    else
      @currentFlow = new MachineFlowController {
        container : @pageContainer
        initial
      }, machine
      @forwardEvent @currentFlow, 'MachineTurnOnStarted'

    @currentFlow.on 'ResourceBecameRunning', @bound 'onResourceBecameRunning'
    @forwardEvent @currentFlow, 'ClosingRequested'


  updateStatus: (event, task) ->

    @currentFlow?.updateStatus event, task


  onResourceBecameRunning: (reason) ->

    machine = @getData()
    { appManager } = kd.singletons

    environmentDataProvider.fetchMachine machine.uid, (_machine) =>
      return appManager.tell 'IDE', 'quit'  unless _machine

      initial = reason is 'BuildCompleted'
      @emit 'IDEBecameReady', _machine, initial
      @emit 'ClosingRequested'  unless reason


  destroy: ->

    super
    @currentFlow?.destroy()
