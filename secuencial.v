module main

import sim
import sim.args as simargs
import sim.img

fn main() {
	args := simargs.parse_args(secuencial: true) ? as simargs.SecuencialArgs

	mut writer := img.ppm_writer_for_fname(args.filename, img.image_settings_from_grid(args.grid)) ?
	defer {
		writer.close()
	}

	height := args.grid.height
	width := args.grid.width
	total_pixels := height * width

	mut results := []sim.SimResult{len: total_pixels}

	handle_request := fn [mut results] (request sim.SimRequest) ? {
		result := sim.compute_result(request)
		results[result.id] = result
	}

	sim.run(args.params, sim.SimRequestHandler(handle_request), args.grid)

	for result in results {
		pixel := img.compute_pixel(result)
		writer.handle_pixel(pixel) or {
			sim.log(@MOD + '.' + @FN + ': pixel handler failed. Error $err')
			break
		}
	}

	writer.write() ?
}
