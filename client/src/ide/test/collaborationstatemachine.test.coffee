expect = require 'expect'

CollabStateMachine = require '../lib/collaboration/collaborationstatemachine'

describe 'CollaborationStateMachine', ->

  it 'has following states', ->

    machine = new CollabStateMachine

    { states } = machine

    expect(states['Loading']).toExist()
    expect(states['ErrorLoading']).toExist()
    expect(states['Resuming']).toExist()
    expect(states['NotStarted']).toExist()
    expect(states['Preparing']).toExist()
    expect(states['ErrorPreparing']).toExist()
    expect(states['Prepared']).toExist()
    expect(states['Creating']).toExist()
    expect(states['ErrorCreating']).toExist()
    expect(states['Active']).toExist()
    expect(states['Ending']).toExist()


  it 'tests Loading state transitions', ->

    machine = newSimpleMachine()
    expect(machine.state).toEqual 'Loading'

    legalStates = ['NotStarted', 'ErrorLoading', 'Resuming']
    illegalStates = [
      'Active', 'Preparing', 'Prepared', 'Creating'
      'ErrorCreating', 'Ending', 'Loading', 'ErrorPreparing'
    ]

    assertLegalTransitions newSimpleMachine, legalStates
    assertIllegalTransitions newSimpleMachine, illegalStates


  it 'tests Resuming state transitions', ->

    legalStates = ['Active']
    illegalStates = [
      'Loading', 'ErrorLoading', 'Resuming', 'NotStarted', 'ErrorPreparing'
      'Preparing', 'Prepared', 'Creating', 'ErrorCreating', 'Ending'
    ]

    assertLegalTransitions resumingMachine, legalStates
    assertIllegalTransitions resumingMachine, illegalStates


  it 'tests ErrorLoading state transitions', ->

    legalStates = ['Loading']
    illegalStates = [
      'Active', 'ErrorLoading', 'Resuming', 'NotStarted', 'ErrorPreparing'
      'Preparing', 'Prepared', 'Creating', 'ErrorCreating', 'Ending'
    ]

    assertLegalTransitions errorLoadingMachine, legalStates
    assertIllegalTransitions errorLoadingMachine, illegalStates


  it 'tests NotStarted state transitions', ->

    legalStates = ['Preparing']
    illegalStates = [
      'Active', 'ErrorLoading', 'Resuming', 'NotStarted'
      'Loading', 'Creating', 'ErrorCreating', 'Ending', 'Prepared'
    ]

    assertLegalTransitions notStartedMachine, legalStates
    assertIllegalTransitions notStartedMachine, illegalStates


  it 'tests Preparing state transitions', ->

    legalStates = ['Prepared', 'ErrorPreparing']
    illegalStates = [
      'Active', 'ErrorLoading', 'Resuming', 'NotStarted'
      'Loading', 'Creating', 'ErrorCreating', 'Ending', 'Preparing'
    ]

    assertLegalTransitions preparingMachine, legalStates
    assertIllegalTransitions preparingMachine, illegalStates


  it 'tests ErrorPreparing state transitions', ->

    legalStates = ['Preparing', 'NotStarted']
    illegalStates = [
      'Active', 'ErrorLoading', 'Resuming', 'ErrorPreparing'
      'Loading', 'Creating', 'ErrorCreating', 'Ending'
    ]

    assertLegalTransitions errorPreparingMachine, legalStates
    assertIllegalTransitions errorPreparingMachine, illegalStates


  it 'tests Prepared state transitions', ->

    legalStates = ['Creating']
    illegalStates = [
      'Active', 'ErrorLoading', 'Resuming', 'NotStarted', 'ErrorPreparing'
      'Loading', 'Prepared', 'ErrorCreating', 'Ending', 'Preparing'
    ]

    assertLegalTransitions preparedMachine, legalStates
    assertIllegalTransitions preparedMachine, illegalStates


  it 'tests Creating state transitions', ->

    legalStates = ['Active', 'ErrorCreating']
    illegalStates = [
      'Creating', 'ErrorLoading', 'Resuming', 'NotStarted'
      'Loading', 'Prepared', 'Ending', 'Preparing', 'ErrorPreparing'
    ]

    assertLegalTransitions creatingMachine, legalStates
    assertIllegalTransitions creatingMachine, illegalStates


  it 'tests ErrorCreating state transitions', ->

    legalStates = ['NotStarted', 'Creating']
    illegalStates = [
      'ErrorCreating', 'ErrorLoading', 'Resuming', 'Active'
      'Loading', 'Prepared', 'Ending', 'Preparing', 'ErrorPreparing'
    ]

    assertLegalTransitions errorCreatingMachine, legalStates
    assertIllegalTransitions errorCreatingMachine, illegalStates


  it 'tests Active state transitions', ->

    legalStates = ['Ending']
    illegalStates = [
      'ErrorCreating', 'ErrorLoading', 'Resuming', 'Active', 'ErrorPreparing'
      'Loading', 'Prepared', 'NotStarted', 'Creating', 'Preparing'
    ]

    assertLegalTransitions activeMachine, legalStates
    assertIllegalTransitions activeMachine, illegalStates


  it 'tests Ending state transitions', ->

    legalStates = []
    illegalStates = [
      'ErrorCreating', 'ErrorLoading', 'Resuming', 'Active', 'ErrorPreparing'
      'Loading', 'Prepared', 'NotStarted', 'Creating', 'Ending', 'Preparing'
    ]

    assertLegalTransitions endingMachine, legalStates
    assertIllegalTransitions endingMachine, illegalStates


assertLegalTransitions = (machineFactoryFn, states) ->
  states.forEach (state) ->
    machine = machineFactoryFn()
    machine.transition state
    expect(machine.state).toEqual state

assertIllegalTransitions = (machineFactoryFn, states) ->
  states.forEach (state) ->
    machine = machineFactoryFn()
    expect(-> machine.transition state).toThrow /illegal state transition/

newSimpleMachine = -> new CollabStateMachine

loadingMachine = -> newSimpleMachine()

resumingMachine = ->
  machine = new CollabStateMachine
  machine.transition 'Resuming'
  return machine

errorLoadingMachine = ->
  machine = new CollabStateMachine
  machine.transition 'ErrorLoading'
  return machine

notStartedMachine = ->
  machine = new CollabStateMachine
  machine.transition 'NotStarted'
  return machine

preparingMachine = ->
  machine = notStartedMachine()
  machine.transition 'Preparing'
  return machine

errorPreparingMachine = ->
  machine = preparingMachine()
  machine.transition 'ErrorPreparing'
  return machine

preparedMachine = ->
  machine = preparingMachine()
  machine.transition 'Prepared'
  return machine

creatingMachine = ->
  machine = preparedMachine()
  machine.transition 'Creating'
  return machine

errorCreatingMachine = ->
  machine = creatingMachine()
  machine.transition 'ErrorCreating'
  return machine

activeMachine = ->
  machine = resumingMachine()
  machine.transition 'Active'
  return machine

endingMachine = ->
  machine = activeMachine()
  machine.transition 'Ending'
  return machine
