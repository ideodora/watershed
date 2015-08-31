fs = require 'fs'

Promise = require 'bluebird'
byline = require 'byline'
chunk = require 'chunk'
glob = require 'glob'
mkdirp = require 'mkdirp'
turf = require 'turf'
sprintf = require('underscore.string').sprintf

tasks = []

sequenceTasks = (tasks) ->

	recordValue = (results, value) ->

		results.push value

		return results

	pushValue = recordValue.bind(null, [])

	return tasks.reduce (promise, task) ->
		return promise.then(task).then(pushValue)
	, Promise.resolve()

createTask = (file, first) ->

	->
		new Promise (resolve, reject) ->

			console.log "file start to parsing... : ", file

			wstream = fs.createWriteStream("index.geojson", flags: 'a')

			unless first
				wstream.write(",")

			stream = fs.createReadStream(file, encoding: 'utf8')

			stream.pipe(wstream, end: false)

			stream.on 'end', ->
				console.log "stream on end"
				wstream.end("\n")

			wstream.on 'finish', ->
				resolve()

glob "geojson/01*.geojson", (err, files) ->

	first = ->
		new Promise (resolve, reject) ->
			prefix = '{"type": "FeatureCollection", "features": [\n'
			fs.writeFile "index.geojson", prefix, ->
				resolve()				

	end = ->
		new Promise (resolve, reject) ->
			suffix = ']}'
			fs.writeFile "index.geojson", suffix, flag: 'a', ->
				resolve()

	tasks.push first

	for file, index in files
		
		if index == 0
			tasks.push createTask(file, true)
		else
			tasks.push createTask(file, false)

	tasks.push end

	sequenceTasks(tasks)	
