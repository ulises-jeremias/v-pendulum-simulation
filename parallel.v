module main

import sim
import sim.args as simargs
import sim.img

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	request_chan := chan sim.SimRequest{}
	result_chan := chan sim.SimResult{}

	mut workers := []thread{cap: args.workers}
	defer {
		request_chan.close()
		result_chan.close()
		sim.log('Waiting for workers to finish')
		workers.wait()
	}

	// start a worker on each core
	for id in 0 .. args.workers {
		workers << go sim.sim_worker(id, request_chan, [result_chan])
	}

	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(args.params, grid: args.grid, on_request: sim.SimRequestHandler(handle_request))

	mut writer := img.ppm_writer_for_fname(args.filename, img.image_settings_from_grid(args.grid)) ?
	defer {
		writer.close()
	}

	img.image_worker(mut writer, result_chan, img.image_settings_from_grid(args.grid))
}
