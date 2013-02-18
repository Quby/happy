key = require "./key"
Route = require "./route"

HTTP_METHODS = ["GET", "POST", "PUT", "DELETE", "HEAD"]

class Router
	constructor: ->
		@routes = []
		@params = {}
		@cache = {}

Router::route = (pattern) ->
	methods = []
	actions = []
	until typeof pattern is "string"
		action = key pattern
		if action in HTTP_METHODS
			methods.push action	
		else
			actions.push action
		pattern = pattern[action]
	@routes.push (new Route actions, methods, pattern)

Router::param = (name, re) ->
	@params[name] = re

Router::matchParams = (params) ->
	for name, val of params
		if val.match @params[name] is null
			return false
	return true

Router::match = (method, url) ->
	for route in @routes
		paramsAndActions = route.match method, url
		if paramsAndActions?
			[params, actions] = paramsAndActions
			if @matchParams params
				return paramsAndActions
	return [{}, []]

module.exports = Router
