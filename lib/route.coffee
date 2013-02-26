class Route
	constructor: (@actions, @methods, pattern) ->
		params = []
	
		pattern = pattern.replace /\:([a-zA-Z0-9]+\??)/g, (_, p) ->
			if p[p.length-1] is "?"
				params.push (p.slice 0, -1)
				return "(.*)"
			else
				params.push p
				return "(.+)"
				
		
		@params = params	
		@pattern = new RegExp "^#{pattern}$"
	
Route::match = (method, url) ->
	if @methods.length > 0 && method not in @methods
		return null
	paramsValues = url.match @pattern
	if paramsValues?
		paramsValues = paramsValues.slice 1
		params = {}
		for param, i in @params
			params[param] = paramsValues[i]
		
		return [params, @actions]			
	else
		return null

module.exports = Route
