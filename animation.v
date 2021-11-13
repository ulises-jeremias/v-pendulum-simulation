module main

import gg
import gx
import runtime
import sim
import sim.args as simargs
import sim.img

// customisable through setting VJOBS
const max_parallel_workers = runtime.nr_jobs()

const bg_color = gx.white

struct Pixel {
	x     f32
	y     f32
	color gx.Color
}

struct App {
	args         simargs.ParallelArgs
	request_chan chan sim.SimRequest
	result_chan  chan sim.SimResult
mut:
	gg     &gg.Context = 0
	pixels [][]gx.Color
}

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

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
		bg_color: bg_color
		frame_fn: frame
		init_fn: init
	)

	defer {
		app.request_chan.close()
		app.result_chan.close()
	}

	// start a worker on each core
	for _ in 0 .. app.args.workers_amount {
		go sim.sim_worker(app.request_chan, [app.result_chan])
	}

	request_chan := app.request_chan
	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(app.args.params, sim.SimRequestHandler(handle_request), app.args.grid)

	app.gg.run()
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

fn pixels_worker(mut app App) {
	for {
		select {
			result := <-app.result_chan {
				// find the closest magnet
				pixel_color := img.compute_pixel(result)

				x, y := get_pixel_coords(app, result)
				app.pixels[y][x] = pixel_color
			}
		}
	}
}
