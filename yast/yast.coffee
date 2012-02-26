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

yast.endpoint = -> url.format 
  protocol: yast.options.location.protocol
  host: yast.options.location.host
  pathname: "#{yast.options.version}/"

yast.requestBase = (method) -> xmlbuilder.create()
  .begin('request').att('req', method)

yast.request = (xml, callback) -> request { 
    method: yast.options.method
    qs: { request: xml }
    uri: yast.endpoint() 
  }, callback

yast.login = (user, password, callback) ->
  reqdoc = yast.requestBase('auth.login')
    .ele('user').txt(user).up()
    .ele('password').txt(password).up()

  console.log reqdoc.toString()
  yast.request reqdoc.toString(), (err, response, body) ->
    return callback err if err  
    result = xmleasy.parse body
    callback null, result, body

module.exports = yast