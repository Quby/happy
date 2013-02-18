Happy = require "happy"

Happy.global()

route foo: bar: baz: "/test/:param"
route some: ha: "/huh/:a/:b"
route post: form: "/hello"
route get: hello: "/hello/:name"

param name: /[a-z]+/

param name: (req, res, next) ->
	req.name = req.params.name
	next()

action hello: (req, res) ->
	res.end "hello #{req.name}"

listen 8000
