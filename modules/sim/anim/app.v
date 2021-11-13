module anim

import gg
import gx
import sim
import sim.args as simargs

const bg_color = gx.white

struct Pixel {
	x     f32
	y     f32
	color gx.Color
}

struct App {
pub:
	args         simargs.ParallelArgs
	request_chan chan sim.SimRequest
	result_chan  chan sim.SimResult
pub mut:
	gg     &gg.Context = 0
	pixels [][]gx.Color
}

pub fn new_app(args simargs.ParallelArgs) &App {
	mut app := &App{
		args: args
		pixels: [][]gx.Color{len: args.grid.height, init: []gx.Color{len: args.grid.width}}
	}
	app.gg = gg.new_context(
		width: args.grid.width
		height: args.grid.height
		create_window: true
		window_title: 'V Pendulum Simulation'
		user_data: app
		bg_color: anim.bg_color
		frame_fn: frame
		init_fn: init
	)
	return app
}

fn init(mut app App) {
	go pixels_worker(mut app)
}

fn get_pixel_coords(app App, result sim.SimResult) (int, int) {
	return int(result.id) % app.args.grid.width, int(result.id) / app.args.grid.height
}

fn frame(mut app App) {
	app.gg.begin()
	for y, row in app.pixels {
		for x, color in row {
			app.gg.set_pixel(x, y, color)
		}
	}
	app.gg.end()
}
