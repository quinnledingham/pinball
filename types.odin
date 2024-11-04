package pinball

import "core:math"

Vector2 :: [2]f32
Vector3 :: [3]f32
Vector4 :: [4]f32

Vector2_i32 :: [2]i32
Vector3_i32 :: [2]i32

EPSILON :: 0.00001
PI :: 3.14159265359

dot_product_v2 :: proc(l: Vector2, r: Vector2) -> f32 {
	return (l.x * r.x) + (l.y * r.y)
}

multiply_v2 :: proc(v: Vector2, r: f32) -> Vector2 {
	return Vector2{ v.x * r, v.y * r }
}

distance :: proc(a: Vector2, b: Vector2) -> f32 {
	dist_x := a.x - b.x
	dist_y := a.y - a.y
	return math.sqrt((dist_x * dist_x) + (dist_y * dist_y))
}

length_squared :: proc(v: Vector3) -> f32 { 
	return (v.x * v.x) + (v.y * v.y) + (v.z * v.z) 
}

normalized :: proc(v: Vector3) -> Vector3 {
	len_sq := length_squared(v)
	if (len_sq < EPSILON) {
		return v
	}

	inverse_length := 1.0 / math.sqrt_f32(len_sq)
	return { v.x * inverse_length, v.y * inverse_length, v.z * inverse_length };
}

multiply_v3 :: proc(v: Vector3, r: f32) -> Vector3 {
	return Vector3{ v.x * r, v.y * r, v.z * r }
}

dot_product_v3 :: proc(l: Vector3, r: Vector3) -> f32 {
	return (l.x * r.x) + (l.y * r.y) + (l.z * r.z)
}

multiply :: proc{ multiply_v2, multiply_v3 }
dot_product :: proc{ dot_product_v2, dot_product_v3 }

cross_product :: proc(l: Vector3, r: Vector3) -> Vector3 {
	return {
		(l.y * r.z - l.z * r.y),
		(l.z * r.x - l.x * r.z),
		(l.x * r.y - l.y * r.x)
	}
}
