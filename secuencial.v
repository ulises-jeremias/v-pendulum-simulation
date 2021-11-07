module main

import flag
import os
import sim

struct Args {
	params         sim.SimParams
	image_settings sim.ImageSettings
	filename       string
}

fn main() {
	args := parse_args() ?

	mut writer := sim.ppm_writer_for_fname(args.filename, args.image_settings) ?
	defer {
		writer.close()
	}

	height := args.image_settings.height
	width := args.image_settings.width
	total_pixels := height * width

	mut results := []sim.SimResult{len: total_pixels}

	handle_request := fn [mut results] (request sim.SimRequest) ? {
		result := sim.compute_result(request)
		results[result.id] = result
	}

	sim.run(args.params, args.image_settings, sim.SimRequestHandler(handle_request))

	for result in results {
		pixel := sim.compute_pixel(result)
		writer.handle_pixel(pixel) or {
			sim.log(@MOD + '.' + @FN + ': pixel handler failed. Error $err')
			break
		}
	}

	writer.write() ?
}

fn parse_args() ?Args {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vps')
	fp.version('v0.1.0')
	fp.limit_free_args(0, 0) ?
	fp.description('This is a pendulum simulation written in pure V')
	fp.skip_executable()

	// output parameters
	width := fp.int('width', `w`, sim.default_width, 'width of the image output. Defaults to $sim.default_width')
	height := fp.int('height', `h`, sim.default_height, 'height of the image output. Defaults to $sim.default_height')
	filename := fp.string('output', `o`, 'out.ppm', 'name of the image output. Defaults to out.ppm')

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
		filename: filename
	}

	sim.log('$args')

	return args
}
