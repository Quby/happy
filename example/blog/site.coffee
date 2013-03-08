Happy = require "happy"
jade = require "happy-jade"

Happy.global()

environment "dev"

plugin jade

require "./routes"
require "./actions/actions"

listen 8000
