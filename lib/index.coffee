http = require "http"
key = require "./key"
Router = require "./router"
Request = require "./request"
Response = require "./response"

###
Application class
@example How to create simple application
  app = new Happy
  app.route hello: "/hello/:name"
  app.param name: /^[A-Z][a-z]*$/
  app.param name: (req, res, next) ->
    req.name = req.params.name
    next()
  app.action hello (req, res) ->
    res.end "Hello, #{req.name}!"
###
class Happy
	constructor: ->
		@paramHandlers = {}
		@actionHandlers = {}
		@router = new Router()
		@config = {}
		
		@extended = false
		@request = class extends Request
		@response = class extends Response
	
	# Connect events with actions
	# @example
	#   app.route event_a: event_b: event_c: "/route/:param"
	route: (pattern) ->
		@router.route pattern

# ##Happy::param name: /RegExp/
# При каждый встрече параметра name производит проверку на соответствие
# ##Happy::param name: cb(req, res, next)
# При каждой встрече параметра name вызывает cb
Happy::param = (x) ->
	name = key x
	x = x[name]
	
	if x instanceof RegExp
		@router.param name, x
	if x instanceof Function
		@paramHandlers[name] = x

# ##Happy::action event: cb(req, res, next)
# Вызывает cb при встрече события event
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

# ##Happy::listen ip, port
# Запускает сервер
Happy::listen = ->
	@server = http.createServer (@onRequest.bind @)
	@server.listen arguments...

# ##Happy::plugin cb(app)
# Позволяет плагину интегрировать свои функции в приложение
Happy::plugin = (plugin) ->
	if typeof plugin is "object"
		if plugin[@config.environment]?
			plugin[@config.environment] @
	else
		plugin @

# ##Happy::environment env
# Устанавливает окружение
Happy::environment = (environment) ->
	@config.environment = environment

# ##Happy.global()
# Создает новое приложение и прописывает его прототипом в глобольное пространство имен
Happy.global = ->
	global.__proto__ = new Happy

module.exports = Happy
