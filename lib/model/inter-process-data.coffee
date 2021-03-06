Serializable = require 'serializable'
{Subscriber, Emitter} = require 'emissary'
_ = require 'underscore-plus'

Host = require './host'

module.exports =
  class InterProcessData
    Serializable.includeInto(this)
    atom.deserializers.add(this)

    Subscriber.includeInto(this)
    Emitter.includeInto(this)

    constructor: (@hostList = []) ->
      for host in @hostList
        @subscribe host, 'changed', => @emit 'contents-changed'
        @subscribe host, 'delete', =>
          @hostList = _.reject(@hostList, ((val) => val == host))
          @emit 'contents-changed'

    serializeParams: ->
      hostList: JSON.stringify(host.serialize() for host in @hostList)

    deserializeParams: (params) ->
      tmpArray = []
      tmpArray.push(Host.deserialize(host)) for host in JSON.parse(params.hostList)
      params.hostList = tmpArray
      params
