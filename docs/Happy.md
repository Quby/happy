#Class: Happy
Application class

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
```coffee
app.route event_a: event_b: event_c: "/route/:param"
```

###Happy::param name: re
Attach regular expression to param
```coffee
app.param id: /^\d+$/
```

###Happy::param name: cb(req, res, next)
Attach action to param
```coffee
app.param page: (req, res, next) ->
	req.page = parseInt req.page
	next()
```
