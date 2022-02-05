module main

import benchmark
import sim
import sim.args as simargs
import sim.img

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	request_chan := chan &sim.SimRequest{}
	result_chan := chan &sim.SimResult{}

	mut writer := img.ppm_writer_for_fname(args.filename, img.image_settings_from_grid(args.grid)) ?

	mut workers := []thread{cap: args.workers + 1}
	mut bmark := benchmark.start()

	defer {
		image_worker := workers.pop()
		request_chan.close()
		sim.log('Waiting for workers to finish')
		workers.wait()
		result_chan.close()
		sim.log('Waiting for image writer to finish')
		image_worker.wait()
		sim.log('Workers finished!')
		bmark.measure(@FN)
		sim.log('Closing writer file')
		writer.close()
		sim.log('Done!')
	}

	for id in 0 .. args.workers {
		workers << go sim.sim_worker(id, request_chan, [result_chan])
	}

	workers << go img.image_worker(mut writer, result_chan, img.image_settings_from_grid(args.grid))

	handle_request := fn [request_chan] (request &sim.SimRequest) ? {
		request_chan <- request
	}

	sim.run(args.params,
		grid: args.grid
		on_request: sim.SimRequestHandler(handle_request)
	)
}
