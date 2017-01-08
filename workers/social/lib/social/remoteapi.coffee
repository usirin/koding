KONFIG    = require 'koding-config-manager'
apiErrors = require './apierrors'
{ clone } = require 'underscore'

publicMethods =
  JAccount: [
    'one'
  ]
  JStackTemplate: [
    'some'
  ]

purify = (data) ->

  if data?.get? then data.get() else data


getConstructorName = (name, Models) ->

  for own model, konstructor of Models
    return model  if model.toLowerCase() is name.toLowerCase()


sendApiError = (res, error) ->

  return res.status(error.status ? 403).send error


sendResponse = (res) -> (err, data) ->

  if err
    sendApiError res, { ok: false, error: err }

  else
    res.status(200)
      .send { ok: true, data }
      .end()


processPayload = (payload, callback) ->

  [ error, data ] = payload[0].arguments

  error ?= null
  data  ?= null

  if Array.isArray data
    data = data.map (_data) -> purify _data
  else
    data = purify data

  payload = { ok: true, error, data }

  callback payload


getToken = (req) ->

  return null  unless req.headers?.authorization
  parts = req.headers.authorization.split ' '

  return null  unless parts.length is 2 and parts[0] is 'Bearer'
  token = parts[1]

  return null  unless typeof token is 'string' and token.length > 0

  return token


parseRequest = (req, res, koding) ->

  { model, id } = req.params

  unless model
    sendApiError res, apiErrors.invalidInput
    return

  [ model, method ] = model.split '.'

  unless method
    sendApiError res, apiErrors.invalidInput
    return

  unless constructorName = getConstructorName model, koding.models
    sendApiError res, apiErrors.invalidInput
    return

  if method in (publicMethods[model] ? [])
    return makeBongoRequest req, res, {
      koding, id, constructorName, method, args: parseArgs req.body
    }

  unless sessionToken = getToken req
    sendApiError res, apiErrors.unauthorizedRequest
    return

  return { model, id, method, sessionToken }


verifySession = (Models, sessionToken, callback) ->

  Models.JSession.one { clientId: sessionToken }, (err, session) ->

    if err or not session
      return callback apiErrors.unauthorizedRequest

    { groupName: group } = session

    callback null, { userArea: { group }, sessionToken }


sendSignatureErr = (signatures, method, res) ->

  # Make signatures human readable ~ GG
  signatures = signatures.map (signature) ->
    [
      signature
        .replace /,F$/, ''
        .replace /O/g, 'Object'
        .replace /S/g, 'String'
        .replace /F/g, 'Function'
        .replace /N/g, 'Number'
        .replace /B/g, 'Boolean'
        .replace /A/g, 'Array'
    ]

  signatures = signatures[0]  if signatures.length is 1
  signaturesMessage = if signatures.length is 1 and signatures[0] is 'Function'
  then 'No parameter required'
  else "Possible signatures are #{JSON.stringify(signatures).replace /"/g, ''}"

  sendApiError res, {
    ok: false
    error: "
      Unrecognized signature for '#{method}' #{signaturesMessage}
    "
    signatures
  }


parseArgs = (body) ->
  body = if body then clone body else null

  args = switch
    when Array.isArray(body) then body
    when Object.keys(body).length then [body]
    else []

  return args.concat [->]

validateBongoOptions = (res, options = {}) ->

  { constructorName, Models, type, method, args } = options

  unless Models[constructorName].getSignature type, method
    sendApiError res, { ok: false, error: 'No such method' }
    return false

  [validCall, signatures] = Models[constructorName].testSignature type, method, args

  unless validCall
    sendSignatureErr signatures, "#{constructorName}.#{method}", res
    return false

  return true

makeBongoRequest = (req, res, options) ->

  { koding, id, args, callbacks, constructorName, method } = options

  type = if id then 'instance' else 'static'

  return  unless validateBongoOptions res, {
    Models: koding.models, constructorName, type, method, args
  }

  bongoRequest = {
    arguments: args
    callbacks: { 1: [args.length - 1] }
    method: {
      constructorName, method, type
    }
  }

  bongoRequest.method.id = id  if id
  req.body.queue = [ bongoRequest ]

  (koding.expressify {
    rateLimitOptions: KONFIG.nodejsRateLimiterForApi
    processPayload
  }) req, res

module.exports = RemoteHandler = (koding) ->

  Models = koding.models

  return (req, res) ->

    res.header 'Access-Control-Allow-Origin', 'http://54.169.209.221:3000'
    res.header 'Access-Control-Allow-Credentials', yes

    return  unless parsedRequest = parseRequest req, res, koding

    { model, id, method, sessionToken } = parsedRequest

    verifySession Models, sessionToken, (err, context) ->

      if err
        sendApiError res, err
        return

      args = parseArgs req.body
      req.body = context

      constructorName = getConstructorName model, koding.models

      makeBongoRequest req, res, {
        koding, id, args, method, constructorName
      }
