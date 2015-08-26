fs = require 'fs'

Promise = require 'bluebird'
byline = require 'byline'
chunk = require 'chunk'
glob = require 'glob'
mkdirp = require 'mkdirp'
turf = require 'turf'
sprintf = require('underscore.string').sprintf
through2 = require 'through2'

# XmlStream = require 'xml-stream'
# GeoJSON = require 'geojson'
# mapshaper = require 'mapshaper'

# mkdirp ""

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

			transform = (chunk, enc, next) ->
				next(null, chunk)

			flush = (cb) ->
				console.log "through on flush"
				this.push("\n")
				cb()
				

			breakLineStream = through2 transform, flush

			wstream = fs.createWriteStream("index.geojson", flags: 'a')

			unless first

				wstream.write(",")

			stream = fs.createReadStream(file, encoding: 'utf8')

			# stream.pipe(breakLineStream).pipe(wstream)

			stream.pipe(wstream, end: false)

			stream.on 'end', ->
				console.log "stream on end"
				wstream.end("\n")
				resolve()

		# geoJsons = []

		# stream.on 'data', (line) ->

		# 	meshCode = new MeshCode(line)

		# 	coords = meshCode.getCoordinate()

		# 	try
		# 		geoJson = turf.polygon coords,
		# 			"fill": "#3333ff"
		# 			"fill-opacity": 0.6
		# 			"stroke": "#0000ff"
		# 			"stroke-opacity": 0.8

		# 		geoJsons.push geoJson
			
		# 	catch e
		# 		console.log e

		# stream.on 'end', ->

		# 	console.log "stream on ended"

		# 	count = geoJsons.length

		# 	console.log "mesh counts: ", count

		# 	counter = 0

		# 	if geoJsons.length > 0
		# 		_ref = undefined

		# 		chunked = chunk(geoJsons, 3000)

		# 		chunkedResults = []

		# 		for bucket in chunked

		# 			_ref2 = undefined

		# 			for geoJson in bucket
						
		# 				if _ref2 == undefined
		# 					_ref2 = geoJson
		# 					continue

		# 				_ref2 = turf.union _ref2, geoJson

		# 				console.log "merge ", code, ": done ", counter++, "/", count, "mesh"
					
		# 			console.log "merge ", code, ": snapshot for batch"
		# 			console.log JSON.stringify(_ref2)

		# 			chunkedResults.push _ref2

		# 		for group in chunkedResults

		# 			if _ref == undefined
		# 				_ref = group
		# 				continue

		# 			_ref = turf.union _ref, group

		# 		fs.writeFile "geojson/" + code + ".geojson", JSON.stringify(_ref), ->
		# 			resolve()

		# 	else
		# 		console.log "no geojson"
		# 		resolve()

		# stream.on 'error', ->
		# 	console.log "stream on error"
		# 	reject()
		

# globkey = process.argv[2] or "01000*"

# globf = "river/%s.txt"
# globString = sprintf(globf, globkey)

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
