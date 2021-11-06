module sim

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
	// 1. add up all forces
	// 2. get an accelleration
	// 3. add to velocity
	// 4. ensure rope constraint is satisfied

	// force due to gravity
	f_gravity := params.get_grav_force(state)

        // force due to magnets
	f_magnet1 := params.get_magnet1_force(state)
	f_magnet2 := params.get_magnet2_force(state)
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
