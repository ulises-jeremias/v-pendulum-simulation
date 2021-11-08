module sim

import math

const (
	max_iterations     = 1000
	simulation_delta_t = 0.0005
)

pub struct SimRequest {
	params SimParams
	state  SimState
pub:
	id u64
}

pub struct SimResult {
	state            SimState
	magnet1_distance f64
	magnet2_distance f64
	magnet3_distance f64
pub:
	id u64
}

pub fn sim_worker(request_chan chan SimRequest, result_channels []chan SimResult) {
	// serve sim requests as they come in
	for {
		request := <-request_chan or { break }
		result := compute_result(request)
		for ch in result_channels {
			ch <- result
		}
	}
}

pub fn compute_result(request SimRequest) SimResult {
	mut state := request.state
	params := request.params

	for _ in 0 .. sim.max_iterations {
		state.increment(sim.simulation_delta_t, params)
		if state.done() {
			println('done!')
			break
		}
	}

	m1_dist := params.get_magnet_dist(0, state)
	m2_dist := params.get_magnet_dist(2.0 * math.pi / 3.0, state)
	m3_dist := params.get_magnet_dist(4.0 * math.pi / 3.0, state)

	return SimResult{
		id: request.id
		state: state
		magnet1_distance: m1_dist
		magnet2_distance: m2_dist
		magnet3_distance: m3_dist
	}
}
