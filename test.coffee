fs = require 'fs'
through2 = require 'through2'
logger = require 'progress-stream'
byline = require 'byline'
util = require 'util'
turf = require 'turf'
_ = require 'underscore'

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
		return "hoge"

transform = (chunk, enc, cb) ->
	string = chunk.toString()
	meshCode = new MeshCode(string)
	coords = meshCode.getCoordinate()

	try
		geoJson = turf.polygon coords,
			"fill": "#3333ff"
			"fill-opacity": 0.6
			"stroke": "#0000ff"
			"stroke-opacity": 0.8
			"rivercode": file
	
	catch e
		console.log e

	this.push geoJson
	cb()

every1000ref = null
every1000count = 1
every1000 = (chunk, enc, cb) ->
	# chunk <geoJson>

	if every1000ref == null
		every1000ref = chunk
		every1000count++
		cb()

	else

		every1000ref = turf.union every1000ref, chunk

		if every1000count == 2
			this.push _.clone(every1000ref)
			every1000ref = null
			every1000count = 1
			cb()
		else
			every1000count++
			cb()

outputer = (chunk, enc, cb) ->
	# this.push ""
	fs.writeFileSync(file, JSON.stringify(chunk) + "\t append \n", flag:'a')
	cb()

file = process.argv[2]

stat = fs.statSync(file)

log = logger
	length: stat.size
	time: 100

log.on 'progress', (progress) ->
	util.log file + " - " + Math.round(progress.percentage) + "% - " + progress.transferred + "/" + progress.length

byline(fs.createReadStream(file))
	.pipe(log)
	.pipe(through2({objectMode: true}, transform))
	.pipe(through2({objectMode: true}, every1000))
	.pipe(through2({objectMode: true}, outputer))
	.pipe(process.stdout)