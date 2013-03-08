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
		@config = {}
		
		@extended = false
		@request = class extends Request
		@response = class extends Response
	
	route: (pattern) ->
		@router.route pattern
	
	param: (x) ->
		name = key x
		x = x[name]
	
		if x instanceof RegExp
			@router.param name, x
		if x instanceof Function
			@paramHandlers[name] = x
	
	###
	Attach action to event
	@param x [event: Function<Request, Response, Function>]
	###
	action: (x) ->
		action = key x
		handler = x[action]
	
		@actionHandlers[action] ?= []
		@actionHandlers[action].push handler

	onRequest: (req, res) ->
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

	###
	@overload listen(ip, port)
	@overload listen(port)
	###
	listen: ->
		@server = http.createServer (@onRequest.bind @)
		@server.listen arguments...

	###
	@overload plugin(plugin)
	  Plug plugin with current environment
	  @param plugin [Object]
	@overload plugin(plugin)
	  Plug plugin
	  @param plugin [Function<Happy>]
	###
	plugin: (plugin) ->
		if typeof plugin is "object"
			if plugin[@config.environment]?
				plugin[@config.environment] @
		else
			plugin @
	
	###
	@param environment [String]
	###
	environment: (environment) ->
		@config.environment = environment

# ##Happy.global()
# Создает новое приложение и прописывает его прототипом в глобольное пространство имен
Happy.global = ->
	global.__proto__ = new Happy

module.exports = Happy
