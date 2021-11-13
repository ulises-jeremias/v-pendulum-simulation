module main

import sim
import sim.anim
import sim.args as simargs

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	mut app := anim.new_app(args)

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
