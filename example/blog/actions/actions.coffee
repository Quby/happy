action post_index: (req, res, next) ->
	if req.params.page?
		req.page = parseInt req.params.page
	else
		req.page = 0
	next()

action post_index: (req, res) ->
	res.render "./test"
