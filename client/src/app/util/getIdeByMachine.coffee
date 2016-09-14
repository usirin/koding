kd = require 'kd'


###*
 * get an IDEAppController based on the machine.
 *
 * @param {Machine} machine - The machine of the IDE you want.
 * @return {IDEAppController}
###
module.exports = getIdeByMachine = (machine) ->
  machineId          = machine._id
  { appControllers } = kd.getSingleton 'appManager'
  ideInstances       = appControllers.IDE?.instances ? []
  for ideController in ideInstances
    if ideController.mountedMachine._id is machineId
      return ideController
