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
###global()
Creates new application as global object
```coffee
Happy.global()

route test: "/test"

action test: (req, res) ->
	res.end "Hello!"

listen 3030
```

##Instance methods

###route [event:] path
Connect events with actions
```coffee
app.route event_a: event_b: event_c: "/route/:param"
```

###param name: re
Attach regular expression to param
```coffee
app.param id: /^\d+$/
```

###param name: cb(req, res, next)
Attach action to param
```coffee
app.param page: (req, res, next) ->
	req.page = parseInt req.page
	next()
```

###action event: cb(req, res, next)
Attach action to event
```coffee
app.action event: cb(req, res, next) ->
  res.end "Hello, World!"
```

###listen [ip], port
Starts http server
```coffee
app.listen 3030
```
```coffee
app.listen 127.0.0.1, 3030
```
