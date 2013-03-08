#Class: Happy
Application class

##Example:
```coffee
app = new Happy
app.route hello: "/hello/:name"
app.param name: /^[A-Z][a-z]*$/
app.param name: (req, res, next) ->
	req.name = req.params.name
	next()
app.action hello (req, res) ->
	res.end "Hello, #{req.name}!"
```

##Static methods
###Happy.global()
Creates new application as global object

##Instance methods
###Happy::route [event:] path
Connect events with actions
####Example
```
app.route event_a: event_b: event_c: "/route/:param"
```
