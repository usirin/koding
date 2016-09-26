{ expect } = require '../../../testhelper'
{ isAddressValid } = require './utils'


describe 'utils::isAddressValid', ->

  it 'should resolve public hostnames and allow', (done) ->
    isAddressValid 'http://google.com/test', (err) ->
      expect(err).to.not.exist
      done()

  it 'should deny private IPs (10.0.0.1)', (done) ->
    isAddressValid '10.0.0.1', (err) ->
      expect(err).to.exist
      expect(err.type).to.be.equal 'PRIVATE_IP'
      done()

  it 'should deny private IPs (127.0.0.1)', (done) ->
    isAddressValid '127.0.0.1', (err) ->
      expect(err).to.exist
      expect(err.type).to.be.equal 'PRIVATE_IP'
      done()

  it 'should deny private IPs (192.168.1.1)', (done) ->
    isAddressValid '192.168.1.1', (err) ->
      expect(err).to.exist
      expect(err.type).to.be.equal 'PRIVATE_IP'
      done()

  it 'should allow public IPs', (done) ->
    isAddressValid '8.8.8.8:3000', (err) ->
      expect(err).to.not.exist
      done()

  it 'should deny wrong addresses', (done) ->
    isAddressValid 'somerandomaddress', (err) ->
      expect(err).to.exist
      expect(err.type).to.be.equal 'NOT_REACHABLE'
      done()

  it 'should support query strings on addresses', (done) ->
    isAddressValid 'yahoo.com?test=foo&bar', (err) ->
      expect(err).to.not.exist
      done()
