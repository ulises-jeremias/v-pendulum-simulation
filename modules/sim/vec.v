module sim

import math

pub struct Vector3D {
	x f64
	y f64
	z f64
}

pub fn vector(data Vector3D) Vector3D {
	return Vector3D{
		...data
	}
}

pub fn (v Vector3D) + (v2 Vector3D) Vector3D {
	return Vector3D{
		x: v.x + v2.x
		y: v.y + v2.y
		z: v.z + v2.z
	}
}

pub fn (v Vector3D) dot(v2 Vector3D) f64 {
	return (v.x * v2.x) + (v.y * v2.y) + (v.z * v2.z)
}

pub fn (v Vector3D) scale(scalar f64) Vector3D {
	return Vector3D{
		x: v.x * scalar
		y: v.y * scalar
		z: v.z * scalar
	}
}

pub fn (v Vector3D) norm_squared() f64 {
	return v.dot(v)
}

pub fn (v Vector3D) norm() f64 {
	return math.sqrt(v.norm_squared())
}
