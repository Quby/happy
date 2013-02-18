http = require "http"
key = require "./key"
Router = require "./router"

class Happy
	constructor: ->
		@paramHandlers = {}
		@actionHandlers = {}
		@router = new Router()
	
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

Happy.global = ->
	global.__proto__ = new Happy

module.exports = Happy
