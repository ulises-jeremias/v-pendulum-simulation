module main

import sim
import sim.anim
import sim.args as simargs

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	mut app := anim.new_app(args)
	mut workers := []thread{cap: args.workers}

	defer {
		app.request_chan.close()
		app.result_chan.close()
		sim.log('Waiting for workers to finish')
		workers.wait()
	}

	// start a worker on each core
	for id in 0 .. args.workers {
		workers << go sim.sim_worker(id, app.request_chan, [app.result_chan])
	}

	request_chan := app.request_chan
	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(args.params, grid: args.grid, on_request: sim.SimRequestHandler(handle_request))

	app.gg.run()
}
