module sim

import math

const (
	iterations         = 1000
	simulation_delta_t = 0.0005
)

pub struct SimRequest {
	id     u64
	params SimParams
mut:
	initial SimState
}

pub struct SimResult {
	SimRequest
	magnet1_distance f64
	magnet2_distance f64
	magnet3_distance f64
}

pub fn sim_worker(request_chan chan SimRequest, result_chan chan SimResult) {
	// serve sim requests as they come in
	for {
		request := <-request_chan or { break }
		result := handle_request(request)
		result_chan <- result
	}
}

fn handle_request(request SimRequest) SimResult {
	mut state := request.initial
	params := request.params

	for _ in 0 .. sim.iterations {
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
		SimRequest: request
		magnet1_distance: m1_dist
		magnet2_distance: m2_dist
		magnet3_distance: m3_dist
	}
}
