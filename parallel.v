module main

import sim
import sim.args as simargs
import sim.img

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	request_chan := chan sim.SimRequest{}
	result_chan := chan sim.SimResult{}
	defer {
		result_chan.close()
		request_chan.close()
	}

	mut writer := img.ppm_writer_for_fname(args.filename, img.image_settings_from_grid(args.grid)) ?
	defer {
		writer.close()
	}

	// start a worker on each core
	for _ in 0 .. args.workers {
		go sim.sim_worker(request_chan, [result_chan])
	}

	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(args.params, sim.SimRequestHandler(handle_request), args.grid)

	img.image_worker(mut writer, result_chan, img.image_settings_from_grid(args.grid))
}
