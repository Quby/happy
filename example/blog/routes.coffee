param page: /^\d+$/

pre "/", (req, res, next) ->
	res.test = "1"
	next()

route post_index: "/"
route post_index: "/:page"
