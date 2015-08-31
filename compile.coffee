fs = require 'fs'

Promise = require 'bluebird'
byline = require 'byline'
chunk = require 'chunk'
glob = require 'glob'
mkdirp = require 'mkdirp'
turf = require 'turf'
sprintf = require('underscore.string').sprintf

# XmlStream = require 'xml-stream'
# GeoJSON = require 'geojson'
# mapshaper = require 'mapshaper'

mkdirp "geojson"

tasks = []

sequenceTasks = (tasks) ->

	recordValue = (results, value) ->

		results.push value

		return results

	pushValue = recordValue.bind(null, [])

	return tasks.reduce (promise, task) ->
		return promise.then(task).then(pushValue)
	, Promise.resolve()

createTask = (file) ->

	new Promise (resolve, reject) ->

		console.log "file start to parsing... : ", file
		code = file.substr(6, 6)

		stream = byline fs.createReadStream(file, encoding:'utf8')

		geoJsons = []

		stream.on 'data', (line) ->

			meshCode = new MeshCode(line)

			coords = meshCode.getCoordinate()

			try
				geoJson = turf.polygon coords,
					"fill": "#3333ff"
					"fill-opacity": 0.6
					"stroke": "#0000ff"
					"stroke-opacity": 0.8
					"rivercode": code

				geoJsons.push geoJson
			
			catch e
				console.log e

		stream.on 'end', ->

			console.log "stream on ended"

			count = geoJsons.length

			console.log "mesh counts: ", count

			counter = 0

			if geoJsons.length > 0
				_ref = undefined

				chunked = chunk(geoJsons, 3000)

				chunkedResults = []

				for bucket in chunked

					_ref2 = undefined

					for geoJson in bucket
						
						if _ref2 == undefined
							_ref2 = geoJson
							continue

						_ref2 = turf.union _ref2, geoJson

						console.log "merge ", code, ": done ", counter++, "/", count, "mesh"
					
					console.log "merge ", code, ": snapshot for batch"
					console.log JSON.stringify(_ref2)

					chunkedResults.push _ref2

				for group in chunkedResults

					if _ref == undefined
						_ref = group
						continue

					_ref = turf.union _ref, group

				fs.writeFile "geojson/" + code + ".geojson", JSON.stringify(_ref), ->
					resolve()

			else
				console.log "no geojson"
				resolve()

		stream.on 'error', ->
			console.log "stream on error"
			reject()
		

globkey = process.argv[2] or "01000*"

globf = "river/%s.txt"
globString = sprintf(globf, globkey)

glob globString, (err, files) ->

	for file in files

		tasks.push createTask(file)

	sequenceTasks(tasks)	

# tasks.reduce (promise, task) ->

# 	promise.then(task).then



# # search_code = process.argv[2]  # "850509"
# # search_file = process.argv[3]  # "5336"

# # stream = fs.createReadStream('../W07-09_' + search_file + '-jgd_GML/W07-09_' + search_file + '-jgd.xml')
# # xml = new XmlStream(stream)

# # writeStream = fs.createWriteStream("./p" + search_code + '-' + search_file + ".json")

# # writeStream.write("[null\n")

class MeshCode

	lat_1 = 3.1 / 3600.0
	lon_1 = 4.6 / 3600.0
	
	constructor: (string) ->

		@source = string.trim().substr(0, 10)

		@code12 = parseInt(@source.substr(0, 2))
		@code5 = parseInt(@source.substr(4, 1))
		@code7 = parseInt(@source.substr(6, 1))
		@code9 = parseInt(@source.substr(8, 1))

		@code34 = parseInt(@source.substr(2, 2))
		@code6 = parseInt(@source.substr(5, 1))
		@code8 = parseInt(@source.substr(7, 1))
		@code10 = parseInt(@source.substr(9, 1))

		@lat = 0.0 + (((@code12 / 1.5) * 3600) + ((@code5 * 5) * 60) + (@code7 * 30) + (@code9 * 3) ) / 3600
		@lon = 0.0 + (((@code34 + 100) * 3600) + ((@code6 * 7.5) * 60) + (@code8 * 45) + (@code10 * 4.5) ) / 3600

	getCoordinate: ->

		return [[
			[@lon, @lat]
			[@lon, @lat + lat_1]
			[@lon + lon_1, @lat + lat_1]
			[@lon + lon_1, @lat]
			[@lon, @lat]
		]]

	debug: ->
		# console.log "@code12:", @code12
		# console.log "@code5:", @code5
		# console.log "@code7:", @code7
		# console.log "@code9:", @code9
		# console.log "@code34:", @code34
		# console.log "@code6:", @code6
		# console.log "@code8:", @code8
		# console.log "@code10:", @code10

		console.log "[@lat @lon] :", @lat, ":", @lon


# # xml.preserve('ksj:ValleyMesh', true)
# # xml.on 'endElement: ksj:ValleyMesh', (item) ->

# # 	mesh_id = item["$"]["gml:id"]
# # 	text = item["gml:rangeSet"]["gml:DataBlock"]["gml:tupleList"]["$text"]
# # 	children = text.trim().split("\n")

# # 	geoJsons = []

# # 	for child in children

# # 		if child.indexOf(',' + search_code + ',') > -1

# # 			meshCode = new MeshCode(child)

# # 			coords = meshCode.getCoordinate()

# # 			try
# # 				geoJson = turf.polygon coords,
# # 					"fill": "#3333ff"
# # 					"fill-opacity": 0.6
# # 					"stroke": "#0000ff"
# # 					"stroke-opacity": 0.8

# # 				geoJsons.push geoJson
				
# # 			catch e
# # 				console.log child
# # 				console.log mesh_id
# # 				console.log mesh_code
# # 				console.log e

# # 	if geoJsons.length > 0
# # 		_ref = undefined

# # 		for geoJson in geoJsons
			
# # 			if _ref == undefined
# # 				_ref = geoJson
# # 				continue

# # 			_ref = turf.union _ref, geoJson
		
# # 		# console.log JSON.stringify(_ref) + ","
# # 		writeStream.write("," + JSON.stringify(_ref) + "\n")

# # xml.on 'end', ->
# # 	writeStream.write("]")
