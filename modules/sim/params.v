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