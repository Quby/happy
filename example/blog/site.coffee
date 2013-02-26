Happy = require "happy"
jade = require "happy-jade"

Happy.global()

plugin jade.dev

require "./routes"
require "./actions/actions"

listen 8000
