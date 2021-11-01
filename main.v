module main

import flag
import os
import sim
import runtime
import term

// customisable through setting VJOBS
const max_parallel_workers = runtime.nr_jobs()

fn main() {
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
	fname := fp.string('output', `o`, 'out.ppm', 'name of the image output. Defaults to out.ppm')

	// simulation parameters
	rope_length := fp.float('rope-length', 0, sim.default_rope_length, 'rope length to use on simulation. Defaults to $sim.default_rope_length')
	bearing_mass := fp.float('bearing-mass', 0, sim.default_bearing_mass, 'bearing mass to use on simulation. Defaults to $sim.default_bearing_mass')
	magnet_spacing := fp.float('magnet-spacing', 0, sim.default_magnet_spacing, 'magnet spacing to use on simulation. Defaults to $sim.default_magnet_spacing')
	magnet_height := fp.float('magnet-height', 0, sim.default_magnet_height, 'magnet height to use on simulation. Defaults to $sim.default_magnet_height')
	magnet_strength := fp.float('magnet-strength', 0, sim.default_magnet_strength, 'magnet strength to use on simulation. Defaults to $sim.default_magnet_strength')
	gravity := fp.float('gravity', 0, sim.default_gravity, 'gravity to use on simulation. Defaults to $sim.default_gravity')

	fp.finalize() or {
		println(fp.usage())
		return
	}

	params := sim.new_sim_params(
		rope_length: rope_length
		bearing_mass: bearing_mass
		magnet_spacing: magnet_spacing
		magnet_height: magnet_height
		magnet_strength: magnet_strength
		gravity: gravity
	)

	$if debug ? {
		println('Amount of Workers: $workers_amount')
		println('Image Filename: $fname')
		println('Width: $width')
		println('Height: $height')
		println('')
		println(params)
	}

	mut writer := sim.ppm_writer_for_fname(fname, width: width, height: height) ?
	defer {
		writer.close()
	}

	result_chan := chan sim.SimResult{}
	request_chan := chan sim.SimRequest{}

	// start a worker on each core
	for _ in 0 .. workers_amount {
		go sim.sim_worker(request_chan, result_chan)
	}

	go fn (request_chan chan sim.SimRequest, params sim.SimParams, image_settings sim.ImageSettings) {
		height := image_settings.height
		width := image_settings.width

		mut index := u64(0)
		println('')
		for y in 0 .. height {
			term.clear_previous_line()
			println('Line: $y')
			for x in 0 .. width {
				// setup initial conditions
				position := sim.new_vector_3d(
					x: 0.1 * ((f64(x) - 0.5 * f64(width - 1)) / f64(width - 1))
					y: 0.1 * ((f64(y) - 0.5 * f64(height - 1)) / f64(height - 1))
					z: 0.0
				)
				velocity := sim.new_vector_3d(x: 0, y: 0, z: 0)

				mut state := sim.new_sim_state(
					position: position
					velocity: velocity
				)

				state.satisfy_rope_constraint(params)
				request_chan <- sim.SimRequest{
					id: index
					initial: state
					params: params
				}
				index++
			}
		}
		request_chan.close()
	}(request_chan, params, width: width, height: height)

	sim.image_worker(mut writer, result_chan, width: width, height: height)
}
