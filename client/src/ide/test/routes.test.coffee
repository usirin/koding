kd            = require 'kd'
nick          = require 'app/util/nick'
mock          = require '../../../mocks/mockingjay'
expect        = require 'expect'
routes        = require 'ide/routes'
dataProvider  = require 'app/userenvironmentdataprovider'

appManager    = kd.singletons.appManager
mockMachine   = mock.getMockMachine()
mockWorkspace = mock.getMockWorkspace()
dataToLoadIDE =
  machine     : mock.getMockMachine()
  username    : mock.getMockAccount().profile.nickname
  workspace   : mock.getMockWorkspace()
  channelId   : '6075644514008039523'

ROUTE_PARAMS           =
  machine              : { params: { machineLabel: 'koding-vm-0' } }
  noMachine            : { params: { machineLabel: 'not-existing-machine' } }
  workspace            : { params: { machineLabel: 'koding-vm-0', workspaceSlug: 'my-workspace' } }
  noWorkspace          : { params: { machineLabel: 'koding-vm-0', workspaceSlug: 'not-existing-workspace' } }
  collaboration        : { params: { machineLabel: '6075649037833338981' } }
  noMachineNoWorkspace : { params: { machineLabel: 'not-existing-machine', workspaceSlug: 'not-existing-workspace' } }


createSpyAndAssert = (spyOn, spyFor, routeType, routeParams) ->

  expect.spyOn spyOn, spyFor
  routes.routeHandler routeType, routeParams

  expect(spyOn[spyFor]).toHaveBeenCalled()


getStorageData = ->

  storage        = kd.singletons.localStorageController.storage 'IDE'
  storageData    =
    machineLabel : mockMachine.slug
    workspaceSlug: mockWorkspace.slug
    channelId    : undefined

  return { storage, storageData }


describe 'IDE.routes', ->

  afterEach -> expect.restoreSpies()


  describe '.routeHandler', ->

    describe 'when home, eg. /IDE', ->

      it 'should routeToLatestWorkspace', ->

        createSpyAndAssert routes, 'routeToLatestWorkspace', 'home'


    describe 'when machine, eg. /IDE/6075649037833338981 or /IDE/koding-vm-0', ->

      it 'should loadCollaborativeIDE if machine label is all digits which we assume it is a channel id related with a collaboration session', ->

        createSpyAndAssert routes, 'loadCollaborativeIDE', 'machine', ROUTE_PARAMS.collaboration


      it 'should fetch machine if machine label contains chars', ->

        createSpyAndAssert dataProvider, 'fetchMachine', 'machine', ROUTE_PARAMS.machine


      it 'should routeToMachineWorkspace if machine is fetched', ->

        mock.envDataProvider.fetchMachine.toReturnMachine()

        expect.spyOn routes, 'routeToMachineWorkspace'
        routes.routeHandler 'machine', ROUTE_PARAMS.machine
        expect(routes.routeToMachineWorkspace).toHaveBeenCalled()


      it 'should routeToLatestWorkspace if no machine is fetched', ->

        mock.envDataProvider.fetchMachine.toReturnNull()
        expect.spyOn routes, 'routeToLatestWorkspace'
        routes.routeHandler 'machine', ROUTE_PARAMS.noMachine
        expect(routes.routeToLatestWorkspace).toHaveBeenCalled()


    describe 'when workspace, eg. IDE/koding-vm-0/my-workspace', ->

      it 'should fetchMachine for the given machine id', ->

        createSpyAndAssert dataProvider, 'fetchMachine', 'workspace', ROUTE_PARAMS.workspace


      it 'should ensureDefaultWorkspace', ->

        mock.envDataProvider.fetchMachine.toReturnMachine()
        mock.envDataProvider.ensureDefaultWorkspace()

        expect.spyOn dataProvider, 'ensureDefaultWorkspace'
        expect.spyOn dataProvider, 'fetchWorkspaceByMachineUId' # to prevent ide load and url change

        routes.routeHandler 'workspace', ROUTE_PARAMS.workspace
        expect(dataProvider.ensureDefaultWorkspace).toHaveBeenCalled()
        expect(dataProvider.fetchWorkspaceByMachineUId).toHaveBeenCalled()


      it 'should routeToLatestWorkspace if there is no machine', ->

        mock.envDataProvider.fetchMachine.toReturnNull()
        mock.envDataProvider.ensureDefaultWorkspace()

        expect.spyOn routes, 'routeToLatestWorkspace'

        routes.routeHandler 'workspace', ROUTE_PARAMS.noMachineNoWorkspace
        expect(routes.routeToLatestWorkspace).toHaveBeenCalled()


      it 'should fetchWorkspaceByMachineUId', ->

        mock.envDataProvider.fetchMachine.toReturnMachine()
        mock.envDataProvider.ensureDefaultWorkspace()

        expect.spyOn dataProvider, 'fetchWorkspaceByMachineUId'

        routes.routeHandler 'workspace', ROUTE_PARAMS.workspace
        expect(dataProvider.fetchWorkspaceByMachineUId).toHaveBeenCalled()


      it 'should loadIDE if machine and workpsace is found', ->

        mock.envDataProvider.fetchMachine.toReturnMachine()
        mock.envDataProvider.ensureDefaultWorkspace()
        mock.envDataProvider.fetchWorkspaceByMachineUId.toReturnWorkspace()

        expect.spyOn routes, 'loadIDE'

        routes.routeHandler 'workspace', ROUTE_PARAMS.workspace
        expect(routes.loadIDE).toHaveBeenCalled()


      it 'should routeToMachineWorkspace if workspace is not found', ->

        mock.envDataProvider.fetchMachine.toReturnMachine()
        mock.envDataProvider.ensureDefaultWorkspace()
        mock.envDataProvider.fetchWorkspaceByMachineUId.toReturnNull()

        expect.spyOn routes, 'routeToMachineWorkspace'

        routes.routeHandler 'workspace', ROUTE_PARAMS.workspace
        expect(routes.routeToMachineWorkspace).toHaveBeenCalled()


  describe '.selectWorkspaceOnSidebar', ->

    it 'should return safely if there is no machine or workspace', ->

      calls = [
        routes.selectWorkspaceOnSidebar()
        routes.selectWorkspaceOnSidebar {}
        routes.selectWorkspaceOnSidebar { machine: {} }
        routes.selectWorkspaceOnSidebar { workspace: {} }
      ]

      expect(call).toBe no  for call in calls


    it.skip 'should call activitySidebar.selectWorkspace', ->

      data                     = { machine: mockMachine, workspace: mockWorkspace }
      { activitySidebar }      = kd.singletons.mainView
      { storage, storageData } = getStorageData()

      sidebarSpy = expect.spyOn activitySidebar, 'selectWorkspace'
      storageSpy = expect.spyOn storage, 'setValue'

      routes.selectWorkspaceOnSidebar data

      expect(activitySidebar.selectWorkspace).toHaveBeenCalled()
      expect(storage.setValue).toHaveBeenCalled()

      [ firstCall, secondCall ] = storageSpy.calls

      expect(firstCall.arguments[0]).toBe 'LatestWorkspace'
      expect(firstCall.arguments[1]).toEqual storageData

      expect(secondCall.arguments[0]).toBe "LatestWorkspace_#{mockMachine.uid}"
      expect(secondCall.arguments[1]).toEqual storageData


  describe '.getLatestWorkspace', ->

    it 'should return safely if there is no workspace', ->

      expect(routes.getLatestWorkspace()).toBe no
      expect(routes.getLatestWorkspace({ uid: 'foo' })).toBe no


    it 'should find the latest workspace', ->

      { storage, storageData } = getStorageData()

      expect.spyOn(storage, 'getValue').andCall -> return storageData
      mock.envDataProvider.findWorkspace.toReturnWorkspace()

      { machineLabel, workspaceSlug, channelId } = storageData

      workspace = routes.getLatestWorkspace mockMachine

      expect(dataProvider.findWorkspace).toHaveBeenCalledWith machineLabel, workspaceSlug, channelId
      expect(workspace).toEqual storageData


    it 'should return undefined if there is no workspace found for the storaged data in localStorage', ->

      { storage, storageData } = getStorageData()

      expect.spyOn(storage, 'getValue').andCall -> return storageData
      mock.envDataProvider.findWorkspace.toReturnNull()

      workspace = routes.getLatestWorkspace mockMachine

      expect(storage.getValue).toHaveBeenCalled()
      expect(workspace).toEqual undefined


  describe '.loadIDENotFound', ->

    it 'should tell ide instance to createMachineStateModal with NotFound state', ->

      fakeApp = {}

      expect.spyOn(appManager, 'open').andCall (appName, options, callback) -> callback fakeApp
      expect.spyOn appManager, 'tell'

      routes.loadIDENotFound()

      expect(fakeApp.amIHost).toBe yes
      expect(appManager.open).toHaveBeenCalled()
      expect(appManager.tell).toHaveBeenCalledWith 'IDE', 'createMachineStateModal', { state: 'NotFound' }


  describe '.routeToFallback', ->


    it 'should routeToMachineWorkspace if there is a machine', ->

      mock.envDataProvider.getMyMachines.toReturnMachines()
      expect.spyOn routes, 'routeToMachineWorkspace'

      routes.routeToFallback()
      expect(routes.routeToMachineWorkspace).toHaveBeenCalledWith mockMachine


    it 'should loadIDENotFound if there is no machine', ->

      mock.envDataProvider.getMyMachines.toReturnEmptyArray()
      expect.spyOn routes, 'loadIDENotFound'

      routes.routeToFallback()
      expect(routes.loadIDENotFound).toHaveBeenCalled()


  describe '.routeToMachineWorkspace', ->


    it 'should route to /IDE/koding-vm-0/foo-workspace if latestWorkspace found', ->

      expectedRoute = '/IDE/koding-vm-0/foo-workspace'

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspace()
      expect.spyOn kd.singletons.router, 'handleRoute'

      routes.routeToMachineWorkspace mockMachine

      expect(kd.singletons.router.handleRoute).toHaveBeenCalledWith expectedRoute

    it 'should route to /IDE/koding-vm-0/my-workspace if latestWorkspace not found', ->

      expectedRoute = '/IDE/koding-vm-0/my-workspace'

      mock.ideRoutes.getLatestWorkspace.toReturnNull()
      expect.spyOn kd.singletons.router, 'handleRoute'

      routes.routeToMachineWorkspace mockMachine

      expect(kd.singletons.router.handleRoute).toHaveBeenCalledWith expectedRoute


    it 'should route to /IDE/ufkk8bca4a8a/my-workspace if machine is permanent', ->

      expectedRoute = '/IDE/ufkk8bca4a8a/foo-workspace'

      mock.machine.isPermanent.toReturnYes()
      mock.ideRoutes.getLatestWorkspace.toReturnWorkspace()
      expect.spyOn kd.singletons.router, 'handleRoute'

      routes.routeToMachineWorkspace mockMachine
      expect(kd.singletons.router.handleRoute).toHaveBeenCalledWith expectedRoute


  describe '.routeToLatestWorkspace', ->


    it 'should routeToFallback if there is no latest workspace', ->

      mock.ideRoutes.getLatestWorkspace.toReturnNull()
      expect.spyOn routes, 'routeToFallback'

      routes.routeToLatestWorkspace()

      expect(routes.routeToFallback).toHaveBeenCalled()


    it 'should fetchMachineByLabel to verify that we still have the jMachine document of the stored machine in localStorage', ->

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspace()
      expect.spyOn dataProvider, 'fetchMachineByLabel'

      routes.routeToLatestWorkspace()

      expect(dataProvider.fetchMachineByLabel).toHaveBeenCalled()


    it 'should route to /IDE/koding-vm-0/foo-workspace after fetching the machine', ->

      expectedRoute = '/IDE/koding-vm-0/foo-workspace'

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspace()
      mock.envDataProvider.fetchMachineByLabel.toReturnMachineAndWorkspace()
      expect.spyOn kd.singletons.router, 'handleRoute'

      routes.routeToLatestWorkspace()

      expect(kd.singletons.router.handleRoute).toHaveBeenCalledWith expectedRoute


    it 'should routeToMachineWorkspace if fetchMachine returns no workspace', ->

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspace()
      mock.envDataProvider.fetchMachineByLabel.toReturnMachine()
      expect.spyOn routes, 'routeToMachineWorkspace'

      routes.routeToLatestWorkspace()
      expect(routes.routeToMachineWorkspace).toHaveBeenCalledWith mockMachine


    it 'should routeToFallback if there is no machine and workspace for the stored data', ->

      mock.envDataProvider.fetchMachineByLabel.toReturnNull()
      expect.spyOn routes, 'routeToFallback'

      routes.routeToLatestWorkspace()
      expect(routes.routeToFallback).toHaveBeenCalled()


    it 'should verify social channel existence if the stored data has channelId info', ->

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspaceWithChannelId()
      expect.spyOn kd.singletons.socialapi, 'cacheable'

      routes.routeToLatestWorkspace()

      expect(kd.singletons.socialapi.cacheable).toHaveBeenCalled()


    it 'should unset LatestWorkspace in localStorage and routeToFallback if socialapi returns an error for the given channelId', ->

      { storage } = getStorageData()

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspaceWithChannelId()
      mock.socialapi.cacheable.toReturnError()
      expect.spyOn storage, 'unsetKey'
      expect.spyOn routes,  'routeToFallback'

      routes.routeToLatestWorkspace()

      expect(storage.unsetKey).toHaveBeenCalledWith 'LatestWorkspace'
      expect(routes.routeToFallback).toHaveBeenCalled()


    it 'should fetchMachineAndWorkspaceByChannelId to verify that we have that machine with the given channelId', ->

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspaceWithChannelId()
      mock.socialapi.cacheable.toReturnChannel()
      expect.spyOn dataProvider, 'fetchMachineAndWorkspaceByChannelId'

      routes.routeToLatestWorkspace()
      expect(dataProvider.fetchMachineAndWorkspaceByChannelId).toHaveBeenCalled()


    it 'should route to /IDE/6075644514008039523 if channelId is still valid and there is machine and the workspace', ->

      expectedRoute = '/IDE/6075644514008039523'

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspaceWithChannelId()
      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnMachineAndWorkspace()
      expect.spyOn kd.singletons.router, 'handleRoute'

      routes.routeToLatestWorkspace()

      expect(kd.singletons.router.handleRoute).toHaveBeenCalledWith expectedRoute


    it 'should routeToFallback if fetchMachineAndWorkspaceByChannelId returns no machine and workspace', ->

      mock.ideRoutes.getLatestWorkspace.toReturnWorkspaceWithChannelId()
      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnNull()
      expect.spyOn routes, 'routeToFallback'

      routes.routeToLatestWorkspace()

      expect(routes.routeToFallback).toHaveBeenCalled()


  describe '.loadCollaborativeIDE', ->


    it 'should validate the channel via socialapi.cacheable request', ->

      mock.socialapi.cacheable.toReturnChannel()
      expect.spyOn kd.singletons.socialapi, 'cacheable'

      routes.loadCollaborativeIDE()

      expect(kd.singletons.socialapi.cacheable).toHaveBeenCalled()


    it 'should routeToLatestWorkspace if socialapi returns an error', ->

      mock.socialapi.cacheable.toReturnError()
      expect.spyOn routes, 'routeToLatestWorkspace'

      routes.loadCollaborativeIDE()

      expect(routes.routeToLatestWorkspace).toHaveBeenCalled()


    it 'should fetchMachineAndWorkspaceByChannelId to validate machine and workpsace belongs to given channelId', ->

      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnMachineAndWorkspace()
      expect.spyOn dataProvider, 'fetchMachineAndWorkspaceByChannelId'

      routes.loadCollaborativeIDE()

      expect(dataProvider.fetchMachineAndWorkspaceByChannelId).toHaveBeenCalled()


    it 'should routeToLatestWorkspace if no workspace for the channelId', ->

      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnNull()
      expect.spyOn routes, 'routeToLatestWorkspace'

      routes.loadCollaborativeIDE()

      expect(routes.routeToLatestWorkspace).toHaveBeenCalled()


    it 'should routeToLatestWorkspace if jAccount.some returns error', ->

      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnMachineAndWorkspace()
      mock.remote.api.JAccount.some.toReturnError()
      expect.spyOn routes, 'routeToLatestWorkspace'

      routes.loadCollaborativeIDE()

      expect(routes.routeToLatestWorkspace).toHaveBeenCalled()


    it 'should loadIDE if account found', ->

      expect.spyOn routes, 'loadIDE'
      mock.socialapi.cacheable.toReturnChannel()
      mock.envDataProvider.fetchMachineAndWorkspaceByChannelId.toReturnMachineAndWorkspace()
      mock.remote.api.JAccount.some.toReturnAccounts()

      routes.loadCollaborativeIDE()

      expect(routes.loadIDE).toHaveBeenCalledWith dataToLoadIDE


  describe '.loadIDE', ->

    testLoadIDEInnerCallback = (callback) ->

      spy     = expect.spyOn(appManager, 'open').andCall (appName, options, callback) -> callback fakeApp
      { uid } = mockMachine
      fakeApp = { mountMachineByMachineUId: -> }

      mock.ideRoutes.findInstance.toReturnNull()
      expect.spyOn fakeApp, 'mountMachineByMachineUId'

      callback()

      expect(appManager.open).toHaveBeenCalled()
      expect(spy.calls.first.arguments[0]).toBe 'IDE'
      expect(spy.calls.first.arguments[1].forceNew).toBe yes
      expect(fakeApp.mountMachineByMachineUId).toHaveBeenCalledWith uid
      expect(fakeApp.mountedMachineUId).toBe uid
      expect(fakeApp.workspaceData).toBe mockWorkspace

      if nick() is dataToLoadIDE.username
        expect(fakeApp.amIHost).toBe yes
      else
        expect(fakeApp.isInSession).toBe       yes
        expect(fakeApp.amIHost).toBe           no
        expect(fakeApp.collaborationHost).toBe dataToLoadIDE.username
        expect(fakeApp.channelId).toBe         dataToLoadIDE.channelId


    it 'should selectWorkspaceOnSidebar', ->

      expect.spyOn routes, 'selectWorkspaceOnSidebar'

      routes.loadIDE dataToLoadIDE

      expect(routes.selectWorkspaceOnSidebar).toHaveBeenCalledWith dataToLoadIDE


    it 'should showInstance if ide is already opened', ->

      mock.ideRoutes.findInstance.toReturnInstance()
      expect.spyOn appManager, 'showInstance'
      expect.spyOn routes, 'selectWorkspaceOnSidebar'
      appManager.appControllers.IDE = {}
      appManager.appControllers.IDE.instances = []

      routes.loadIDE dataToLoadIDE

      expect(appManager.showInstance).toHaveBeenCalled()
      expect(routes.selectWorkspaceOnSidebar).toHaveBeenCalled()


    it 'should open IDE if there is no open ide app instance', ->

      appManager.appControllers.IDE = null

      testLoadIDEInnerCallback -> routes.loadIDE dataToLoadIDE


    it 'should open IDE if ide instance not found but there is open ide instances', ->

      appManager.appControllers.IDE = {}
      appManager.appControllers.IDE.instances = []

      testLoadIDEInnerCallback -> routes.loadIDE dataToLoadIDE


  describe '.findInstance', ->


    it 'should return undefined if there is no ide app instance', ->

      appManager.appControllers.IDE = { instances: [] }

      instance = routes.findInstance mockMachine, { getId: -> }

      expect(instance).toBe undefined


    it 'should return the appInstance if there is a match', ->

      ws = {}
      ws[key]  = value for own key, value of mockWorkspace
      ws.getId = -> ws._id

      appManager.appControllers.IDE =
        instances: [
          {
            foo              : 'bar'
            workspaceData    : ws
            mountedMachineUId: mockMachine.uid
          }
        ]

      instance = routes.findInstance mockMachine, ws
      expect(instance.foo).toBe 'bar'
