http = require "http"
key = require "./key"
Router = require "./router"
Request = require "./request"
Response = require "./response"

class Happy
	constructor: ->
		@paramHandlers = {}
		@actionHandlers = {}
		@router = new Router()
		
		@extended = false
		@request = class extends Request
		@response = class extends Response
	
Happy::route = (pattern) ->
	@router.route pattern
	
Happy::param = (x) ->
	name = key x
	x = x[name]
	
	if x instanceof RegExp
		@router.param name, x
	if x instanceof Function
		@paramHandlers[name] = x

Happy::action = (x) ->
	action = key x
	handler = x[action]
	
	@actionHandlers[action] ?= []
	@actionHandlers[action].push handler

Happy::onRequest = (req, res) ->
	unless @extended
		@request.prototype.__proto__.__proto__ = req.__proto__
		@response.prototype.__proto__.__proto__ = res.__proto__
		@extended = true
	
	req.__proto__ = @request.prototype
	res.__proto__ = @response.prototype
	[params, actions] = @router.match req.method, req.url
	req.params = params
	callbacks = []
	
	for param of params
		if @paramHandlers[param]?
			callbacks.push @paramHandlers[param]
	for action in actions
		callbacks = callbacks.concat (@actionHandlers[action] ? [])
	
	next = () ->
		unless callbacks.length is 0
			callbacks.shift() req, res, next
		else
			res.end "404"
	next()

Happy::listen = ->
	@server = http.createServer (@onRequest.bind @)
	@server.listen arguments...

Happy::plugin = (plugin) ->
	plugin @

Happy.global = ->
	global.__proto__ = new Happy

module.exports = Happy
