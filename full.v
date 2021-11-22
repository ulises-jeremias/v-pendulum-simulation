module main

import sim
import sim.anim
import sim.args as simargs
import sim.img

fn main() {
	args := simargs.parse_args() ? as simargs.ParallelArgs

	mut app := anim.new_app(args)
	mut workers := []thread{cap: args.workers}

	img_result_chan := chan sim.SimResult{}
	defer {
		img_result_chan.close()
		app.request_chan.close()
		app.result_chan.close()
		sim.log('Waiting for workers to finish')
		workers.wait()
	}

	// start a worker on each core
	for id in 0 .. app.args.workers {
		workers << go sim.sim_worker(id, app.request_chan, [app.result_chan, img_result_chan])
	}

	request_chan := app.request_chan
	handle_request := fn [request_chan] (request sim.SimRequest) ? {
		request_chan <- request
	}

	go sim.run(app.args.params,
		grid: app.args.grid
		on_request: sim.SimRequestHandler(handle_request)
	)

	mut writer := img.ppm_writer_for_fname(args.filename, img.image_settings_from_grid(args.grid)) ?
	defer {
		writer.close()
	}
	go img.image_worker(mut writer, img_result_chan, img.image_settings_from_grid(args.grid))

	app.gg.run()
}
