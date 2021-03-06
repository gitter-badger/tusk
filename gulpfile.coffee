fs         = require("fs")
gulp       = require("gulp")
header     = require("gulp-header")
coffee     = require("gulp-cjsx")
mocha      = require("gulp-mocha")
source     = require("vinyl-source-stream")
browserify = require("browserify")
details    = require("./package.json")
src        = "./src"
lib        = "./lib"
tests      = "./test"

try fs.mkdirSync(__dirname + lib)

###
Build all local cs.
###
gulp.task("build", ->
	gulp.src("#{src}/**/*.coffee")
		.pipe(coffee(bare: true, join: true).on("error", handleError = (err)->
			console.log(err.toString())
			console.log(err.stack)
			this.emit("end")
		))
		.pipe(header("/** #{details.name} v#{details.version} https://www.npmjs.com/package/#{details.name} */\n"))
		.pipe(gulp.dest(lib))
)

###
# Build js for browser tests.
###
gulp.task "build-browser", ->
	browserify(
		entries: ("#{tests}/#{file}" for file in fs.readdirSync("./test") when file.endsWith("Test.coffee"))
		extensions: [".coffee"]
		debug: true
	)
		.ignore("mocha-jsdom")
		.transform("coffee-reactify")
		.bundle()
		.pipe(source("run.js"))
		.pipe(gulp.dest("#{tests}"))
		.on("error", (err)->
			return unless err
			console.log(err.toString())
			console.log(err.stack)
			@emit("end")
		)


###
Run tests.
###
gulp.task("test", ->
	gulp.src("#{tests}/*Test.coffee", read: false)
		.pipe(mocha())
)
