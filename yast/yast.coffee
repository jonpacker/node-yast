# CoffeeScript Yast API?

xmlbuilder = require 'xmlbuilder'
xmleasy = require 'libxmljs-easy'
request = require 'request'
url = require 'url'

yast = {}

yast.options = 
  version: '1.0'
  location:
    protocol: 'http'
    host: 'www.yast.com'
  method: 'GET'

# Construct the endpoint. 
yast.endpoint = (options = yast.options) -> url.format 
  protocol: options.location.protocol
  host: options.location.host
  pathname: "#{yast.options.version}/"

# Construct a base XMLBuilder object - <request req='`method`'></request>
yast.requestBase = (method) -> xmlbuilder.create()
  .begin('request').att('req', method)

# Perform a request to the YAST API with the given XML. 
yast.request = (xml, callback, options = yast.options) -> request { 
    method: options.method
    qs: { request: xml }
    uri: yast.endpoint(options) 
  }, callback

# Login method. Callback format: ƒ(err, hash)
yast.login = (user, password, callback) ->
  reqdoc = yast.requestBase('auth.login')
    .ele('user').txt(user).up()
    .ele('password').txt(password).up()

  yast.request reqdoc.toString(), (err, response, body) ->
    return callback err if err  
    result = xmleasy.parse body
    callback null, result, body

module.exports = yast