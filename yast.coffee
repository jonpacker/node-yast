# CoffeeScript Yast API?

xmlbuilder = require 'xmlbuilder'
xmlparser = require 'libxml-to-js'
_ = require 'underscore'
request = require 'request'
url = require 'url'
async = require 'async'

yast = {}

yast.options =
  version: '1.0'
  location:
    protocol: 'http'
    host: 'www.yast.com'
  method: 'GET'
  statusCodes:
    '0': 'Success'
    '1': 'Unknown error'
    '3': 'Access denied'
    '4': 'Not logged in'
    '5': 'Login failure'
    '6': 'Invalid input'
    '7': 'Subscription required'
    '8': 'Data format error'
    '9': 'No request (remember to set the Content-Type header)'
    '10': 'Invalid request'
    '11': 'Missing fields'
    '12': 'Request too large'
    '13': 'Server maintenance'

# Construct the endpoint. 
yast.endpoint = (options = yast.options) -> url.format
  protocol: options.location.protocol
  host: options.location.host
  pathname: "#{yast.options.version}/"

# Construct a base XMLBuilder object - <request req='`method`'></request>
yast.requestBase = (method, user) ->
  base = xmlbuilder.create()
    .begin('request').att('req', method)

  return base if not user?

  base.ele('user').txt(user.user).up()
    .ele('hash').txt(user.hash).up()

# The "Groomer". Check parser results to see if they were yast errors.
yast.groom = (errCallback, okCallback) ->
  (err, response, body) ->
    return errCallback err if err
    xmlparser body, (err, result) ->
      if err
        return errCallback(err)
      if not ('@' of result) or not ('status' of result['@'])
        return errCallback('Unknown error')
      if result['@'].status isnt '0'
        return errCallback(yast.options.statusCodes[result['@'].status])
      okCallback(result)

# Perform a request to the YAST API with the given XML. 
yast.request = (xml, callback, options = yast.options) -> request {
    method: options.method
    qs: { request: xml }
    uri: yast.endpoint(options)
  }, callback

# Requests a generic set of objects with the given name using the given API
# function
yast.objectRequest = (user, functionName, objectName, params = {}, callback) ->
  reqdoc = yast.requestBase functionName, user
  reqdoc.ele(paramName).txt(value).up() for paramName, value of params

  yast.request reqdoc.toString(), yast.groom callback, (result) ->
    callback null, result.objects[objectName] || []

# Login method. Callback format: ƒ(err, user). The return object contains the 
# user and hash and is used as a key to all of the other API functions.
yast.login = (user, password, callback) ->
  reqdoc = yast.requestBase('auth.login')
    .ele('user').txt(user).up()
    .ele('password').txt(password).up()

  yast.request reqdoc.toString(), yast.groom callback, (result) ->
    callback null, user: user, hash: result.hash

yast.folders = (user, callback) ->
  yast.objectRequest user, 'data.getFolders', 'folder', {}, callback
yast.projects = (user, callback) ->
  yast.objectRequest user, 'data.getProjects', 'project', {}, callback
yast.recordTypes = (user, callback) ->
  yast.objectRequest user, 'meta.getRecordTypes', 'recordType', {}, callback

# Params can be typeId, parentId, timeFrom and timeTo.
# see http://www.yast.com/wiki/index.php/API:data.getRecords for more details.
yast.rawRecords = (user, params, callback) ->
  yast.objectRequest user, 'data.getRecords', 'record', params, callback

yast.records = (user, params, callback) ->
  yast.objectRequest user, 'data.getRecords', 'record', params, (err, records) ->
    return callback(err) if err
    prettifyRecord = (record) ->
      return {
        id: record.id,
        start: record.variables.v[0]['#'],
        finish: record.variables.v[1]['#'],
        desc: record.variables.v[2]['#'],
        rate: record.variables.v[5]['#'],
        billable: record.variables.v[6]['#'] is '1',
        project: record.project
      }
    callback null, records.map(prettifyRecord)

# Get info about the user with the given details
yast.user = (user, callback) ->
  reqdoc = yast.requestBase('user.getInfo', user)
  yast.request reqdoc.toString(), yast.groom callback, (result) ->
    callback null, result

# Retrieve a tree structure that combines all of the given collections of objects (records, folders or projects)
yast.treeify = (objectCollections) ->
  collectChildren = (collection, parentId = '0') ->
    (object for object in collection when object.parentId is parentId)

  addTree = (parent) ->
    children = (yast.collectChildren collection, parent.id for collection in objectCollections)
    parent.children = _.flatten(children, true)
    addTree child for child in parent.children

  rootNodes = (object for object in _.flatten(objectCollections, true) when object.parentId is '0')
  addTree rootNode for rootNode in rootNodes

  return rootNodes

yast.projectTree = (user, callback) -> yast.tree user, callback, false
yast.tree = (user, callback, includeRecords = true) ->
  yast.multiUserTree [user], callback, includeRecords

yast.multiUserTree = (users, callback, includeRecords = true) ->
  done = (objs...) -> callback null, yast.treeify objs

  # todo - improve this somehow from 'just' using the first user.
  yast.folders _.first(users), (err, folders) ->
    return callback err if err
    yast.projects _.first(users), (err, projects) ->
      return callback err if err
      return done folders, projects if not includeRecords
      async.parallel ( ((cb) -> yast.records user, {}, cb) for user in users ), (err, allRecords) ->
          return callback err if err
          done folders, projects, _.flatten(allRecords, true)

module.exports = yast
