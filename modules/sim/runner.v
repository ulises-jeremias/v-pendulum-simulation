module sim

import term

pub type SimRequestHandler = fn (request SimRequest) ?

pub const (
	default_width  = 600
	default_height = 600
)

[params]
pub struct GridSettings {
pub:
	width  int = sim.default_width
	height int = sim.default_height
}

pub fn new_grid_settings(settings GridSettings) GridSettings {
	return GridSettings{
		...settings
	}
}

pub fn run(params SimParams, handle_request SimRequestHandler, grid_settings GridSettings) {
	height := grid_settings.height
	width := grid_settings.width

	mut index := u64(0)
	log('')
	for y in 0 .. height {
		$if verbose ? {
			term.clear_previous_line()
		}
		log(@MOD + '.' + @FN + ': y: ${y + 1}')
		for x in 0 .. width {
			// setup state conditions
			position := vector(
				x: 0.1 * ((f64(x) - 0.5 * f64(width - 1)) / f64(width - 1))
				y: 0.1 * ((f64(y) - 0.5 * f64(height - 1)) / f64(height - 1))
				z: 0.0
			)
			velocity := vector(x: 0, y: 0, z: 0)

			mut state := new_state(
				position: position
				velocity: velocity
			)

			state.satisfy_rope_constraint(params)
			request := SimRequest{
				id: index
				state: state
				params: params
			}
			handle_request(request) or {
				log(@MOD + '.' + @FN + ': request handler failed. Error $err')
				break
			}
			index++
		}
	}
}
