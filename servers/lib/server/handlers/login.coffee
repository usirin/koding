{ getClientId
  handleClientIdNotFound
  setSessionCookie
} = require './../helpers'

koding                     = require './../bongo'

module.exports = (req, res) ->

  res.header 'Access-Control-Allow-Origin', 'http://54.169.209.221:3000'
  res.header 'Access-Control-Allow-Credentials', yes

  { JUser } = koding.models
  { username, password, tfcode, redirect, groupName, token } = req.body

  clientId =  getClientId req, res

  return handleClientIdNotFound res, req unless clientId

  options = { username, password, tfcode, groupName, invitationToken: token }

  JUser.login clientId, options, (err, info) ->

    if err
      return res.status(403).send err.message
    else if not info
      return res.status(500).send 'An error occurred'

    setSessionCookie res, info.replacementToken

    res
      .json { clientId: info.replacementToken }
      .end()
