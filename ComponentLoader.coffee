noflo = require 'noflo'
fs = require 'fs'

module.exports = (loader, done) ->
  dirs = [
    "test_components"
    "components"
  ]
  for dir in dirs
    for file in fs.readdirSync dir
      m = file.match /^(\w+)\.coffee$/
      continue unless m
      path = __dirname + "/#{dir}/#{file}"
      loader.registerComponent 'xpress', m[1], path
  done()
