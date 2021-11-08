module main

import flag
import gg
import gx
import os
import sim
import runtime

// customisable through setting VJOBS
const max_parallel_workers = runtime.nr_jobs()

const bg_color = gx.white

struct Pixel {
	x     f32
	y     f32
	color gx.Color
}

struct Args {
	params         sim.SimParams
	image_settings sim.ImageSettings
	workers_amount int = max_parallel_workers
}

struct App {
	Args
	request_chan chan sim.SimRequest
	result_chan  chan sim.SimResult
mut:
	gg     &gg.Context = 0
	pixels [][]gx.Color
}

fn init(mut app App) {
	// start a worker on each core
	for _ in 0 .. app.workers_amount {
		go sim.sim_worker(app.request_chan, [app.result_chan])
	}
	request_chan := app.request_chan
	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(app.params, app.image_settings, sim.SimRequestHandler(handle_request))

        go pixels_worker(mut app)
}

fn get_pixel_coords(app App, result sim.SimResult) (int, int) {
	return int(result.id) % app.image_settings.width, int(result.id) / app.image_settings.height
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
				pixel_color := sim.compute_pixel(result)

				x, y := get_pixel_coords(app, result)
				app.pixels[y][x] = pixel_color
			}
		}
	}
}

fn main() {
	args := parse_args() ?

	request_chan := chan sim.SimRequest{}
	result_chan := chan sim.SimResult{}
	defer {
		result_chan.close()
		request_chan.close()
	}

	mut app := &App{
		Args: args
		pixels: [][]gx.Color{len: args.image_settings.height, init: []gx.Color{len: args.image_settings.width}}
	}
	app.gg = gg.new_context(
		width: args.image_settings.width
		height: args.image_settings.height
		create_window: true
		window_title: 'V Pendulum Simulation'
		user_data: app
		bg_color: bg_color
		frame_fn: frame
		init_fn: init
	)
	
        app.gg.run()
}

fn parse_args() ?Args {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vps')
	fp.version('v0.1.0')
	fp.limit_free_args(0, 0) ?
	fp.description('This is a pendulum simulation written in pure V')
	fp.skip_executable()

	workers_amount := fp.int('workers', 0, max_parallel_workers, 'amount of workers to use on simulation. Defaults to $max_parallel_workers')

	// output parameters
	width := fp.int('width', `w`, sim.default_width, 'width of the image output. Defaults to $sim.default_width')
	height := fp.int('height', `h`, sim.default_height, 'height of the image output. Defaults to $sim.default_height')

	// simulation parameters
	rope_length := fp.float('rope-length', 0, sim.default_rope_length, 'rope length to use on simulation. Defaults to $sim.default_rope_length')
	bearing_mass := fp.float('bearing-mass', 0, sim.default_bearing_mass, 'bearing mass to use on simulation. Defaults to $sim.default_bearing_mass')
	magnet_spacing := fp.float('magnet-spacing', 0, sim.default_magnet_spacing, 'magnet spacing to use on simulation. Defaults to $sim.default_magnet_spacing')
	magnet_height := fp.float('magnet-height', 0, sim.default_magnet_height, 'magnet height to use on simulation. Defaults to $sim.default_magnet_height')
	magnet_strength := fp.float('magnet-strength', 0, sim.default_magnet_strength, 'magnet strength to use on simulation. Defaults to $sim.default_magnet_strength')
	gravity := fp.float('gravity', 0, sim.default_gravity, 'gravity to use on simulation. Defaults to $sim.default_gravity')

	fp.finalize() or {
		println(fp.usage())
		return none
	}

	params := sim.sim_params(
		rope_length: rope_length
		bearing_mass: bearing_mass
		magnet_spacing: magnet_spacing
		magnet_height: magnet_height
		magnet_strength: magnet_strength
		gravity: gravity
	)

	image_settings := sim.new_image_settings(
		width: width
		height: height
	)

	args := Args{
		params: params
		image_settings: image_settings
		workers_amount: workers_amount
	}

	sim.log('$args')

	return args
}
