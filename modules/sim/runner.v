module sim

import term

pub type SimRequestHandler = fn (request SimRequest) ?

pub fn run(params SimParams, image_settings ImageSettings, handle_request SimRequestHandler) {
	height := image_settings.height
	width := image_settings.width

	mut index := u64(0)
	log('')
	for y in 0 .. height {
		term.clear_previous_line()
		log(@MOD + '.' + @FN + ': image line ${y + 1}')
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
