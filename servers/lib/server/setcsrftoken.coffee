KONFIG = require 'koding-config-manager'
{ v4: createId } = require 'node-uuid'

module.exports = setCrsfToken = (req, res, next) ->

  unless KONFIG.environment is 'production'
    #res.header 'Access-Control-Allow-Origin', 'http://dev.koding.com:4000'
    res.header 'Access-Control-Allow-Origin', 'http://54.169.209.221:3000'
    res.header 'Access-Control-Allow-Credentials', yes

  next()  if req?.cookies?._csrf

  { maxAge, secure } = KONFIG.sessionCookie

  csrfToken = createId()
  # set cookie as pending cookie
  req.pendingCookies or= {}
  req.pendingCookies._csrf = csrfToken

  expires = new Date Date.now() + 360
  res.cookie '_csrf', csrfToken, { expires, secure }

  res
    .json { token: req.pendingCookies._csrf }
    .end()
