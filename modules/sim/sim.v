module sim

import math

pub const (
	default_rope_length     = 0.25
	default_bearing_mass    = 0.03
	default_magnet_spacing  = 0.05
	default_magnet_height   = 0.03
	default_magnet_strength = 10.0
	default_gravity         = 4.9
)

[params]
pub struct SimParams {
	rope_length     f64 = sim.default_rope_length
	bearing_mass    f64 = sim.default_bearing_mass
	magnet_spacing  f64 = sim.default_magnet_spacing
	magnet_height   f64 = sim.default_magnet_height
	magnet_strength f64 = sim.default_magnet_strength
	gravity         f64 = sim.default_gravity
}

pub fn new_sim_params(params SimParams) SimParams {
	return SimParams{
		...params
	}
}

pub fn (params SimParams) get_rope_vector(state SimState) Vector3D {
	rope_origin := new_vector_3d(z: params.rope_length)

	return state.position.add(rope_origin.scale(-1))
}

pub fn (params SimParams) get_grav_force(state SimState) Vector3D {
	return new_vector_3d(z: -params.bearing_mass * params.gravity)
}

pub fn (params SimParams) get_magnet_position(theta f64) Vector3D {
	return new_vector_3d(
		x: math.cos(theta) * params.magnet_spacing
		y: math.sin(theta) * params.magnet_spacing
		z: -params.magnet_height
	)
}

pub fn (params SimParams) get_magnet_force(theta f64, state SimState) Vector3D {
	magnet_position := params.get_magnet_position(theta)
	mut diff := magnet_position.add(state.position.scale(-1))
	distance_squared := diff.norm_squared()
	diff = diff.scale(1.0 / math.sqrt(distance_squared))
	return diff.scale(params.magnet_strength / distance_squared)
}

pub fn (params SimParams) get_magnet_dist(theta f64, state SimState) f64 {
	return params.get_magnet_position(theta).add(state.position.scale(-1)).norm()
}

pub fn (params SimParams) get_magnet1_force(state SimState) Vector3D {
	return params.get_magnet_force(0.0 * math.pi / 3.0, state)
}

pub fn (params SimParams) get_magnet2_force(state SimState) Vector3D {
	return params.get_magnet_force(2.0 * math.pi / 3.0, state)
}

pub fn (params SimParams) get_magnet3_force(state SimState) Vector3D {
	return params.get_magnet_force(4.0 * math.pi / 3.0, state)
}

pub fn (params SimParams) get_tension_force(state SimState, f_passive Vector3D) Vector3D {
	rope_vector := params.get_rope_vector(state)
	rope_vector_norm := rope_vector.scale(1.0 / rope_vector.norm())
	return rope_vector_norm.scale(-1.0 * rope_vector_norm.dot(f_passive))
}

pub struct SimState {
mut:
	position Vector3D
	velocity Vector3D
	accel    Vector3D
}

pub fn new_sim_state(state SimState) SimState {
	return SimState{
		...state
	}
}

pub fn (mut state SimState) satisfy_rope_constraint(params SimParams) {
	mut rope_vector := params.get_rope_vector(state)
	rope_vector = rope_vector.scale(params.rope_length / rope_vector.norm())
	state.position = new_vector_3d(z: params.rope_length).add(rope_vector)
}

pub fn (mut state SimState) increment(delta_t f64, params SimParams) {
	// basically just add up all forces =>
	// get an accelleration =>
	// add to velocity =>
	// ensure rope constraint is satisfied

	// force due to gravity
	f_gravity := params.get_grav_force(state)

	// force due to each magnet
	f_magnet1 := params.get_magnet1_force(state)

	// force due to each magnet
	f_magnet2 := params.get_magnet2_force(state)

	// force due to each magnet
	f_magnet3 := params.get_magnet3_force(state)

	// passive forces
	f_passive := f_gravity.add(f_magnet1.add(f_magnet2.add(f_magnet3)))

	// force due to tension of the rope
	f_tension := params.get_tension_force(state, f_passive)

	// sum up all the fores
	f_sum := f_tension.add(f_passive)

	// get the acceleration
	accel := f_sum.scale(1.0 / params.bearing_mass)
	state.accel = accel

	// update the velocity
	state.velocity = state.velocity.add(accel.scale(delta_t))

	// update the position
	state.position = state.position.add(state.velocity.scale(delta_t))

	// ensure the position satisfies rope constraint
	state.satisfy_rope_constraint(params)
}

pub fn (state SimState) done() bool {
	return state.velocity.norm() < 0.05 && state.accel.norm() < 0.01
}
